<#
.SYNOPSIS
    Spec Kit - Workspace Bootstrap & Update (Windows)
.DESCRIPTION
    First run  : wizard that creates the spec project from the GitHub template,
                 links (or creates) a codebase project, generates the VS Code
                 .code-workspace file, and optionally installs Python/mkdocs deps.
    Subsequent : detects the existing SPEC-KIT installation via tools/.speckit,
                 checks for upstream updates against the template repo, and
                 offers an interactive update flow.
.NOTES
    Requirements: PowerShell 5.1+, git.
    Optional: gh (GitHub CLI), python 3.8+, code (VS Code CLI).
.LINK
    https://github.com/lksnext-ai-lab/spec-kit-template
#>
[CmdletBinding()]
param(
    [switch]$WorkspaceOnly,
    [switch]$NoVenv,
    [switch]$NoOpen,
    [switch]$Yes,
    [switch]$DryRun,
    [switch]$Check,
    [switch]$Update
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ===================================================================
# CONSTANTS
# ===================================================================

$TEMPLATE_REPO  = 'lksnext-ai-lab/spec-kit-template'
$TEMPLATE_URL   = "https://github.com/${TEMPLATE_REPO}.git"
$SCRIPT_VERSION = '2.3.0' # x-release-please-version

$SPECKIT_FILE   = 'tools/.speckit'

$MANAGED_PATHS = @(
    '.github/agents',
    '.github/instructions',
    '.github/prompts',
    '.github/skills',
    '.github/workflows',
    '.github/copilot-instructions.md',
    '.github/CODEOWNERS',
    '.github/PULL_REQUEST_TEMPLATE.md',
    'docs/kit',
    'tools',
    'VERSION',
    'mkdocs.yml',
    'CONTRIBUTING.md',
    'DCO.txt',
    'LICENSE',
    'NOTICE',
    'TRADEMARKS.md'
)

# ESC character for ANSI â€” works in PowerShell 5.1+
$ESC = [char]0x1b

# TUI geometry
$HEADER_HEIGHT = 14
$STEP_AREA_HEIGHT = 14
$PROGRESS_HEIGHT = 4
$STEP_AREA_TOP = $HEADER_HEIGHT
$PROGRESS_TOP = $HEADER_HEIGHT + $STEP_AREA_HEIGHT

# Colors
$C_RESET  = $ESC + '[0m'
$C_BOLD   = $ESC + '[1m'
$C_DIM    = $ESC + '[2m'
$C_GREEN  = $ESC + '[32m'
$C_YELLOW = $ESC + '[33m'
$C_CYAN   = $ESC + '[38;5;208m'  # LKS brand orange
$C_RED    = $ESC + '[31m'
$C_BLUE   = $ESC + '[34m'
$C_WHITE  = $ESC + '[97m'
$C_CLR_LN = $ESC + '[K'
$C_HIDE   = $ESC + '[?25l'
$C_SHOW   = $ESC + '[?25h'

# State
$script:useTui = $false
$script:stepResults = @{}
$script:totalSteps = 5
$script:currentStep = 0
$script:projectName = ''
$script:specName = ''
$script:baseDir = ''
$script:specMode = ''
$script:specOrg = ''
$script:specVisibility = ''
$script:specPath = ''
$script:codebaseMode = ''
$script:codebasePath = ''
$script:codebaseUrl = ''
$script:codebaseName = ''
$script:installVenv = $false
$script:installExtensions = $false
$script:openVsCode = $false
$script:runMode = 'install' # 'install' or 'update'
$script:headerAnimated = $false

$script:stepLabels = @('Prerequisites', 'Project', 'Spec repo', 'Codebase', 'Extras')

# ===================================================================
# TUI HELPERS
# ===================================================================

function Test-TuiSupport {
    if ([Console]::IsOutputRedirected) { return $false }
    try {
        $h = [Console]::WindowHeight
        return ($h -ge ($HEADER_HEIGHT + $STEP_AREA_HEIGHT + $PROGRESS_HEIGHT + 2))
    } catch {
        return $false
    }
}

function Set-CursorAt([int]$row, [int]$col) {
    if ($script:useTui) {
        [Console]::SetCursorPosition($col, $row)
    }
}

function Clear-StepArea {
    if (-not $script:useTui) {
        Clear-Host
        Show-Header
        return
    }
    Set-CursorAt $STEP_AREA_TOP 0
    for ($i = 0; $i -lt $STEP_AREA_HEIGHT; $i++) {
        Write-Host "${C_CLR_LN}"
    }
    Set-CursorAt $STEP_AREA_TOP 0
}

function Write-C([string]$text) {
    Write-Host $text
}

function Write-Pad([string]$text, [int]$indent) {
    if ($indent -le 0) { $indent = 2 }
    Write-Host ((' ' * $indent) + $text)
}

# ===================================================================
# HEADER
# ===================================================================

function Show-BootAnimation {
    Write-Host $C_HIDE -NoNewline
    Clear-Host

    # Raw logo lines (62 chars wide to fit the box)
    $logo = @(
        '      _____ ____  ___________     __ __ __________            ',
        '     / ___// __ \/ ____/ ___/    / //_//  _/_  __/            ',
        '     \__ \/ /_/ / __/ / /       / ,<   / /  / /               ',
        '    ___/ / ____/ /___/ /___    / /| |_/ /  / /                ',
        '   /____/_/   /_____/\____/   /_/ |_/___/ /_/                 '
    )
    $subtitle  = 'Workspace Bootstrap'
    $byline    = 'by LKS Next'
    $pool = '@#$%&*=+~:;!?<>{}[]|^/\-_.'.ToCharArray()
    $rng  = [System.Random]::new()
    $border   = "  ${C_CYAN}${C_BOLD}+==============================================================+${C_RESET}"
    $emptyRow = "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"

    # Draw static frame once
    Write-C ''                       # row 0
    Write-C $border                  # row 1
    Write-C $emptyRow                # row 2
    # Logo placeholder rows 3-7
    for ($r = 0; $r -lt 5; $r++) {
        Write-C "  ${C_CYAN}|${C_RESET}$(' ' * 62)${C_CYAN}|${C_RESET}"
    }
    Write-C $emptyRow                # row 8
    # Subtitle + byline placeholder rows 9-10
    Write-C "  ${C_CYAN}|${C_RESET}$(' ' * 62)${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}$(' ' * 62)${C_CYAN}|${C_RESET}"
    Write-C $emptyRow                # row 11
    Write-C $border                  # row 12

    $logoStartRow = 3
    $subRow  = 9
    $byRow   = 10

    # ── Phase 1: Scramble resolve — 12 frames ─────────────────────
    $ratios = @(0, 0, 5, 10, 18, 28, 40, 52, 65, 78, 88, 95)
    foreach ($pct in $ratios) {
        for ($r = 0; $r -lt 5; $r++) {
            [Console]::SetCursorPosition(4, $logoStartRow + $r)
            $chars = $logo[$r].ToCharArray()
            $output = ''
            for ($ci = 0; $ci -lt $chars.Length; $ci++) {
                if ($chars[$ci] -eq ' ') {
                    $output += ' '
                } elseif ($rng.Next(100) -lt $pct) {
                    $output += $chars[$ci]
                } else {
                    $output += $pool[$rng.Next($pool.Length)]
                }
            }
            Write-Host "${C_DIM}${output}${C_RESET}" -NoNewline
        }
        Start-Sleep -Milliseconds 90
    }

    # ── Phase 2: Full logo revealed with bold color ───────────────
    for ($r = 0; $r -lt 5; $r++) {
        [Console]::SetCursorPosition(4, $logoStartRow + $r)
        # SPEC part in white bold, KIT part in orange bold
        $raw = $logo[$r]
        $specPart = $raw.Substring(0, 30)
        $kitPart  = $raw.Substring(30)
        Write-Host "${C_BOLD}${C_WHITE}${specPart}${C_RESET}${C_BOLD}${C_CYAN}${kitPart}${C_RESET}" -NoNewline
    }
    Start-Sleep -Milliseconds 200

    # ── Phase 3: Typewriter subtitle ──────────────────────────────
    [Console]::SetCursorPosition(6, $subRow)
    foreach ($ch in $subtitle.ToCharArray()) {
        Write-Host "${C_DIM}${ch}${C_RESET}" -NoNewline
        Start-Sleep -Milliseconds 25
    }
    # Version number — appears instantly
    $verText = "v${SCRIPT_VERSION}"
    $verCol  = 4 + 62 - $verText.Length - 4
    [Console]::SetCursorPosition($verCol, $subRow)
    Write-Host "${C_DIM}${verText}${C_RESET}" -NoNewline
    Start-Sleep -Milliseconds 100

    # ── Phase 4: Typewriter byline ────────────────────────────────
    [Console]::SetCursorPosition(6, $byRow)
    foreach ($ch in $byline.ToCharArray()) {
        Write-Host "${C_DIM}${ch}${C_RESET}" -NoNewline
        Start-Sleep -Milliseconds 30
    }

    Start-Sleep -Milliseconds 400

    # Move cursor past the frame
    [Console]::SetCursorPosition(0, 13)
    Write-Host $C_SHOW -NoNewline
}

function Show-Header {
    # Animated intro: runs whenever console is interactive (not just full TUI)
    $isInteractive = -not [Console]::IsOutputRedirected
    if ($isInteractive -and (-not $script:headerAnimated)) {
        $script:headerAnimated = $true
        Show-BootAnimation
        # Animation already drew the full header — pad to fixed height
        $headerLines = 13
        for ($i = $headerLines; $i -lt $HEADER_HEIGHT; $i++) { Write-C '' }
        return
    }
    if ($script:useTui) { Clear-Host }

    Write-C ''
    Write-C "  ${C_CYAN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}      ${C_BOLD}${C_WHITE}_____ ____  ___________${C_RESET}     ${C_BOLD}${C_CYAN}__ __ __________${C_RESET}            ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}     ${C_BOLD}${C_WHITE}/ ___// __ \/ ____/ ___/${C_RESET}    ${C_BOLD}${C_CYAN}/ //_//  _/_  __/${C_RESET}            ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}     ${C_BOLD}${C_WHITE}\__ \/ /_/ / __/ / /${C_RESET}       ${C_BOLD}${C_CYAN}/ ,<   / /  / /${C_RESET}               ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}    ${C_BOLD}${C_WHITE}___/ / ____/ /___/ /___${C_RESET}    ${C_BOLD}${C_CYAN}/ /| |_/ /  / /${C_RESET}                ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}   ${C_BOLD}${C_WHITE}/____/_/   /_____/\____/${C_RESET}   ${C_BOLD}${C_CYAN}/_/ |_/___/ /_/${C_RESET}                 ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_DIM}Workspace Bootstrap${C_RESET}                              ${C_DIM}v${SCRIPT_VERSION}${C_RESET}     ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_DIM}by LKS Next${C_RESET}                                                 ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}${C_BOLD}+==============================================================+${C_RESET}"
    # Pad header to fixed height
    $headerLines = 13
    for ($i = $headerLines; $i -lt $HEADER_HEIGHT; $i++) { Write-C '' }
}

# ===================================================================
# PROGRESS BAR
# ===================================================================

function Show-ProgressBar {
    if (-not $script:useTui) { return }
    $savedRow = [Console]::CursorTop
    $savedCol = [Console]::CursorLeft

    Set-CursorAt $PROGRESS_TOP 0
    for ($i = 0; $i -lt $PROGRESS_HEIGHT; $i++) { Write-Host "${C_CLR_LN}" }
    Set-CursorAt $PROGRESS_TOP 0

    $pct = 0
    if ($script:totalSteps -gt 0) {
        $pct = [math]::Floor(($script:currentStep / $script:totalSteps) * 100)
    }
    $filled = [math]::Floor(($script:currentStep / $script:totalSteps) * 40)
    $empty  = 40 - $filled
    $barFill  = '=' * $filled
    $barEmpty = '-' * $empty
    Write-C "  ${C_DIM}Step $($script:currentStep)/${script:totalSteps}${C_RESET} ${C_CYAN}${barFill}${barEmpty}${C_RESET}  ${C_BOLD}${pct}%${C_RESET}"
    Write-C ''

    $line = '  '
    for ($i = 0; $i -lt $script:stepLabels.Count; $i++) {
        $lbl = $script:stepLabels[$i]
        if ($i -lt $script:currentStep) {
            $line += "${C_GREEN}[ok] ${lbl}${C_RESET}  "
        } elseif ($i -eq $script:currentStep) {
            $line += "${C_CYAN}${C_BOLD}> ${lbl}${C_RESET}  "
        } else {
            $line += "${C_DIM}[ ] ${lbl}${C_RESET}  "
        }
    }
    Write-C $line

    [Console]::SetCursorPosition($savedCol, $savedRow)
}

# ===================================================================
# STEP DISPLAY
# ===================================================================

function Show-StepHeader([string]$title) {
    Clear-StepArea
    $num = $script:currentStep + 1
    Write-C ''
    Write-Pad "${C_BOLD}${C_WHITE}STEP ${num} / $($script:totalSteps) -- ${title}${C_RESET}" 2
    Write-Pad "${C_DIM}$('_' * 56)${C_RESET}" 2
    Write-C ''
}

# ===================================================================
# INPUT HELPERS
# ===================================================================

function Read-Value([string]$prompt, [string]$default, [switch]$Required) {
    $dd = ''
    if ($default) { $dd = " ${C_DIM}[${default}]${C_RESET}" }
    Write-Host "  ${C_CYAN}>${C_RESET} ${prompt}${dd}: " -NoNewline
    $val = Read-Host
    if ([string]::IsNullOrWhiteSpace($val)) {
        if ($default) { return $default }
        if ($Required) {
            Write-Pad "${C_RED}Value required.${C_RESET}" 2
            return (Read-Value $prompt $default -Required:$Required)
        }
        return ''
    }
    return $val.Trim()
}

function Read-YesNo([string]$prompt, [bool]$default) {
    $hint = 'y/N'
    if ($default) { $hint = 'Y/n' }
    Write-Host "  ${C_CYAN}>${C_RESET} ${prompt} ${C_DIM}[${hint}]${C_RESET}: " -NoNewline
    $val = Read-Host
    if ([string]::IsNullOrWhiteSpace($val)) { return $default }
    return ($val -match '^[yYsS]')
}

function Read-Continue {
    Write-C ''
    Write-Host "  ${C_DIM}Press Enter to continue...${C_RESET}" -NoNewline
    Read-Host | Out-Null
}

# ===================================================================
# INTERACTIVE SELECTOR (arrow keys + context hints)
# ===================================================================

function Read-InteractiveChoice {
    param(
        [string]$Title,
        [string[]]$Options,
        [string[]]$Hints,
        [int]$Default = 0
    )

    # Fallback if output is redirected (no interactive TUI)
    if ([Console]::IsOutputRedirected) {
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $num = $i + 1
            $marker = ''
            if ($i -eq $Default) { $marker = " ${C_GREEN}<- default${C_RESET}" }
            Write-Pad "${C_BOLD}[${num}]${C_RESET} $($Options[$i])${marker}" 4
        }
        Write-C ''
        $defNum = $Default + 1
        Write-Host "  ${C_CYAN}>${C_RESET} Choose ${C_DIM}[${defNum}]${C_RESET}: " -NoNewline
        $val = Read-Host
        if ([string]::IsNullOrWhiteSpace($val)) { return $Default }
        $num = 0
        if ([int]::TryParse($val, [ref]$num) -and $num -ge 1 -and $num -le $Options.Count) {
            return ($num - 1)
        }
        return $Default
    }

    $selected = $Default
    $optCount = $Options.Count
    # Calculate how many lines we render so we can erase them
    # Title(1) + blank(1) + options(n) + blank(1) + hint box(6) + blank(1) + footer(1) = n + 11
    $hintBoxHeight = 6
    $totalLines = 1 + 1 + $optCount + 1 + $hintBoxHeight + 1 + 1

    # Hide cursor during selection
    Write-Host $C_HIDE -NoNewline

    try {
        while ($true) {
            # Save cursor position
            $startRow = [Console]::CursorTop

            # Title
            Write-Pad "${C_BOLD}${C_WHITE}${Title}${C_RESET}" 2
            Write-C ''

            # Options
            for ($i = 0; $i -lt $optCount; $i++) {
                if ($i -eq $selected) {
                    Write-Pad "${C_CYAN}${C_BOLD}--> * $($Options[$i])${C_RESET}" 4
                } else {
                    Write-Pad "${C_DIM}    o $($Options[$i])${C_RESET}" 4
                }
            }

            Write-C ''

            # Hint box
            $hint = ''
            if ($Hints -and $selected -lt $Hints.Count) {
                $hint = $Hints[$selected]
            }
            $boxWidth = 55
            Write-Pad "${C_DIM}+$('-' * $boxWidth)+${C_RESET}" 4
            # Wrap hint text into lines
            $hintLines = @()
            if ($hint) {
                $words = $hint -split '\s+'
                $line = ''
                foreach ($w in $words) {
                    if (($line.Length + $w.Length + 1) -gt ($boxWidth - 4)) {
                        $hintLines += $line
                        $line = $w
                    } else {
                        if ($line) { $line += ' ' }
                        $line += $w
                    }
                }
                if ($line) { $hintLines += $line }
            }
            # Pad to fixed height (4 content lines)
            while ($hintLines.Count -lt 4) { $hintLines += '' }
            for ($i = 0; $i -lt 4; $i++) {
                $content = $hintLines[$i]
                $padLen = $boxWidth - 2 - $content.Length
                if ($padLen -lt 0) { $padLen = 0 }
                Write-Pad "${C_DIM}|${C_RESET}  ${content}$(' ' * $padLen)${C_DIM}|${C_RESET}" 4
            }
            Write-Pad "${C_DIM}+$('-' * $boxWidth)+${C_RESET}" 4

            Write-C ''

            # Footer
            $pos = "$($selected + 1)/${optCount}"
            Write-Pad "${C_DIM}Up/Down Navigate   Enter Select${C_RESET}                       ${C_DIM}${pos}${C_RESET}" 2

            # Read key
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                'UpArrow'   { $selected = [Math]::Max(0, $selected - 1) }
                'DownArrow' { $selected = [Math]::Min($optCount - 1, $selected + 1) }
                'Enter'     {
                    Write-Host $C_SHOW -NoNewline
                    # Clear selector area
                    [Console]::SetCursorPosition(0, $startRow)
                    for ($i = 0; $i -lt $totalLines; $i++) { Write-Host "${C_CLR_LN}" }
                    [Console]::SetCursorPosition(0, $startRow)
                    # Show final selection
                    Write-Pad "${C_GREEN}[ok]${C_RESET} $($Options[$selected])" 4
                    return $selected
                }
            }

            # Erase and redraw
            [Console]::SetCursorPosition(0, $startRow)
            for ($i = 0; $i -lt $totalLines; $i++) { Write-Host "${C_CLR_LN}" }
            [Console]::SetCursorPosition(0, $startRow)
        }
    } finally {
        Write-Host $C_SHOW -NoNewline
    }
}

# ===================================================================
# PREREQUISITE CHECKS
# ===================================================================

function Get-ToolVersion([string]$cmd, [string[]]$vargs) {
    try {
        $output = & $cmd @vargs 2>&1 | Select-Object -First 1
        if ($output -match '(\d+\.\d+[\.\d]*)') { return $Matches[1] }
        return '?'
    } catch {
        return $null
    }
}

function Test-Prerequisites {
    $script:currentStep = 0
    Show-StepHeader 'Checking prerequisites'
    Show-ProgressBar

    $tools = @(
        @{ Name = 'git';    Cmd = 'git';    Args = @('--version');    Required = $true;  Label = 'Git' },
        @{ Name = 'code';   Cmd = 'code';   Args = @('--version');    Required = $false; Label = 'VS Code' },
        @{ Name = 'gh';     Cmd = 'gh';     Args = @('--version');    Required = $false; Label = 'GitHub CLI' },
        @{ Name = 'python'; Cmd = 'python'; Args = @('--version');    Required = $false; Label = 'Python' }
    )

    $allGood = $true
    foreach ($tool in $tools) {
        $ver = Get-ToolVersion $tool.Cmd $tool.Args
        if ($ver) {
            Write-Pad "${C_GREEN}[ok]${C_RESET} $($tool.Label) ${C_DIM}${ver}${C_RESET}" 4
            $script:stepResults[$tool.Name] = $ver
        } elseif ($tool.Required) {
            Write-Pad "${C_RED}[!!] $($tool.Label) -- REQUIRED (install and retry)${C_RESET}" 4
            $allGood = $false
        } else {
            Write-Pad "${C_YELLOW}[  ] $($tool.Label) -- not found (optional)${C_RESET}" 4
            $script:stepResults[$tool.Name] = $null
        }
    }

    Write-C ''
    if (-not $allGood) {
        Write-Pad "${C_RED}Aborting: missing required tools.${C_RESET}" 2
        exit 1
    }

    Write-Pad "${C_GREEN}All required tools found.${C_RESET}" 4
    Read-Continue

    $script:currentStep = 1
    Show-ProgressBar
}

# ===================================================================
# STEP 1 -- PROJECT NAME & LOCATION
# ===================================================================

function Get-ProjectConfig {
    Show-StepHeader 'Project name and location'
    Show-ProgressBar

    $name = Read-Value 'Project name (e.g. mi-app)' '' -Required
    $slug = ($name -replace '[^a-zA-Z0-9_-]', '-').Trim('-').ToLower()
    if ($slug -ne $name) {
        Write-Pad "Normalized to: ${C_BOLD}${slug}${C_RESET}" 4
    }

    Write-C ''
    $bd = Read-Value 'Base directory' (Get-Location).Path
    if (-not (Test-Path $bd)) {
        if (Read-YesNo "Directory '${bd}' does not exist. Create it?" $true) {
            if (-not $DryRun) { New-Item -Path $bd -ItemType Directory -Force | Out-Null }
            Write-Pad "${C_GREEN}[ok]${C_RESET} Created ${bd}" 4
        } else {
            Write-Pad "${C_RED}Aborting.${C_RESET}" 2
            exit 1
        }
    }

    $script:projectName = $slug
    $script:specName    = "spec-${slug}"
    $resolvedBd = Resolve-Path $bd -ErrorAction SilentlyContinue
    if ($resolvedBd) {
        $script:baseDir = $resolvedBd.Path
    } else {
        $script:baseDir = $bd
    }

    $script:currentStep = 2
    Show-ProgressBar
    Start-Sleep -Milliseconds 300
}

# ===================================================================
# STEP 2 -- SPEC REPOSITORY
# ===================================================================

function Get-SpecConfig {
    Show-StepHeader 'Spec repository'
    Show-ProgressBar

    $hasGh = ($null -ne $script:stepResults['gh'])

    $options = @()
    $hints   = @()
    if ($hasGh) {
        $options += 'Create from GitHub template'
        $hints   += 'Creates a new private/public repo in your GitHub org using the spec-kit-template. Requires the GitHub CLI (gh) to be installed and authenticated.'
    } else {
        $options += 'Create from GitHub template (gh not found)'
        $hints   += 'Requires the GitHub CLI (gh) which was not found. Install gh and authenticate first, then re-run the bootstrap.'
    }
    $options += 'Clone template locally'
    $hints   += 'Clones the spec-kit-template repo and reinitializes git history. You get a fresh local repo that you can push to any remote later. Best for GitLab, Bitbucket, or Azure DevOps.'
    $options += 'Use existing spec repo'
    $hints   += 'Point to a spec repo already cloned on your machine. The bootstrap will link it to the workspace without modifying it.'

    $defaultChoice = 1
    if (-not $hasGh) { $defaultChoice = 1 }
    $choice = Read-InteractiveChoice -Title 'How do you want to set up the spec repository?' -Options $options -Hints $hints -Default $defaultChoice

    switch ($choice) {
        0 {
            if (-not $hasGh) {
                Write-Pad "${C_YELLOW}gh CLI not found. Falling back to clone.${C_RESET}" 4
                $script:specMode = 'clone'
            } else {
                Write-C ''
                $org = Read-Value 'GitHub org/user for the new repo' 'lksnext-ai-lab'
                $visChoice = Read-InteractiveChoice -Title 'Repository visibility' -Options @('Private', 'Public') -Hints @(
                    'The repository will only be visible to you and collaborators you explicitly grant access to.',
                    'The repository will be visible to everyone on the internet. Choose this for open-source projects.'
                ) -Default 0
                $script:specMode  = 'template'
                $script:specOrg   = $org
                $script:specVisibility = if ($visChoice -eq 0) { 'private' } else { 'public' }
            }
        }
        1 { $script:specMode = 'clone' }
        2 {
            Write-C ''
            $p = Read-Value 'Path to existing spec repo' '' -Required
            if (-not (Test-Path (Join-Path $p 'docs/spec'))) {
                Write-Pad "${C_YELLOW}Warning: docs/spec/ not found in path. Continuing anyway.${C_RESET}" 4
            }
            $script:specMode = 'existing'
            $script:specPath = $p
        }
    }

    $script:currentStep = 3
    Show-ProgressBar
    Start-Sleep -Milliseconds 300
}

# ===================================================================
# STEP 3 -- CODEBASE
# ===================================================================

function Get-CodebaseConfig {
    Show-StepHeader 'Codebase project'
    Show-ProgressBar

    $options = @(
        'Existing local repo',
        'Clone from URL',
        'Create empty (git init)',
        'Skip (no codebase for now)'
    )
    $hints = @(
        'Link an existing codebase project already on your machine. The bootstrap adds it to the VS Code workspace as a second root folder (read-only from spec perspective).',
        'Clone a remote Git repository as the codebase folder. It will be added as a second root in the VS Code workspace.',
        'Creates a new empty folder with git initialized. Perfect for greenfield projects where the codebase does not exist yet.',
        'Do not add a codebase folder now. You can add one later by editing the .code-workspace file manually.'
    )
    $choice = Read-InteractiveChoice -Title 'How do you want to set up the codebase project?' -Options $options -Hints $hints -Default 0

    switch ($choice) {
        0 {
            Write-C ''
            $p = Read-Value 'Path to codebase repo' '' -Required
            if (-not (Test-Path $p)) {
                Write-Pad "${C_RED}Path not found: ${p}${C_RESET}" 4
                Get-CodebaseConfig
                return
            }
            $script:codebaseMode = 'existing'
            $script:codebasePath = (Resolve-Path $p).Path
            $script:codebaseName = Split-Path $p -Leaf
        }
        1 {
            Write-C ''
            $url = Read-Value 'Git clone URL' '' -Required
            $dirName = Read-Value 'Local folder name' $script:projectName
            $script:codebaseMode = 'clone'
            $script:codebaseUrl  = $url
            $script:codebaseName = $dirName
        }
        2 {
            $script:codebaseMode = 'empty'
            $script:codebaseName = $script:projectName
        }
        3 {
            $script:codebaseMode = 'skip'
            $script:codebaseName = $null
        }
    }

    $script:currentStep = 4
    Show-ProgressBar
    Start-Sleep -Milliseconds 300
}

# ===================================================================
# STEP 4 -- OPTIONAL SETUP
# ===================================================================

function Get-ExtrasConfig {
    Show-StepHeader 'Optional setup'
    Show-ProgressBar

    $hasPython = ($null -ne $script:stepResults['python'])
    $hasCode   = ($null -ne $script:stepResults['code'])

    $script:installVenv = $false
    $script:installExtensions = $false
    $script:openVsCode  = $false

    if ($hasPython -and (-not $NoVenv)) {
        $script:installVenv = Read-YesNo 'Create Python venv and install mkdocs + tools?' $true
    } elseif (-not $hasPython) {
        Write-Pad "${C_DIM}[  ] Python venv -- skipped (python not found)${C_RESET}" 4
    }

    if ($hasCode) {
        $script:installExtensions = Read-YesNo 'Install recommended VS Code extensions?' $false
        if (-not $NoOpen) {
            $script:openVsCode = Read-YesNo 'Open VS Code when done?' $true
        }
    } else {
        Write-Pad "${C_DIM}[  ] VS Code extensions -- skipped (code not found)${C_RESET}" 4
    }

    $script:currentStep = 5
    Show-ProgressBar
    Start-Sleep -Milliseconds 300
}

# ===================================================================
# EXECUTION HELPERS
# ===================================================================

function Get-RelPath([string]$from, [string]$to) {
    try {
        return [System.IO.Path]::GetRelativePath($from, $to) -replace '\\', '/'
    } catch {
        $fromUri = New-Object System.Uri("$from\")
        $toUri   = New-Object System.Uri($to)
        $rel     = $fromUri.MakeRelativeUri($toUri).ToString()
        return [Uri]::UnescapeDataString($rel) -replace '\\', '/'
    }
}

function Write-Task([string]$label, [string]$status) {
    switch ($status) {
        'running' { Write-Pad "${C_CYAN}[..]${C_RESET} ${label}${C_DIM}...${C_RESET}" 4 }
        'done'    { Write-Pad "${C_GREEN}[ok]${C_RESET} ${label}" 4 }
        'skip'    { Write-Pad "${C_DIM}[  ] ${label} -- skipped${C_RESET}" 4 }
        'fail'    { Write-Pad "${C_RED}[!!]${C_RESET} ${label}" 4 }
    }
}

function Write-TaskDetail([string]$detail) {
    Write-Pad "${C_DIM}    ${detail}${C_RESET}" 6
}

# ===================================================================
# .speckit FILE MANAGEMENT
# ===================================================================

function Write-SpecKitFile([string]$specDir, [string]$mode) {
    $filePath = Join-Path $specDir $SPECKIT_FILE
    $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $content = @"
{
  "version": "${SCRIPT_VERSION}",
  "installed": "${now}",
  "updated": null,
  "template": "${TEMPLATE_REPO}",
  "mode": "${mode}",
  "managed": [
    ".github/agents",
    ".github/instructions",
    ".github/prompts",
    ".github/skills",
    ".github/workflows",
    ".github/copilot-instructions.md",
    ".github/CODEOWNERS",
    ".github/PULL_REQUEST_TEMPLATE.md",
    "docs/kit",
    "tools",
    "VERSION",
    "mkdocs.yml",
    "CONTRIBUTING.md",
    "DCO.txt",
    "LICENSE",
    "NOTICE",
    "TRADEMARKS.md"
  ]
}
"@
    if (-not $DryRun) {
        $content | Set-Content $filePath -Encoding UTF8
    }
}

function Read-SpecKitFile([string]$specDir) {
    $filePath = Join-Path $specDir $SPECKIT_FILE
    if (-not (Test-Path $filePath)) { return $null }
    try {
        $raw = Get-Content $filePath -Raw -Encoding UTF8
        return ($raw | ConvertFrom-Json)
    } catch {
        return $null
    }
}

function Update-SpecKitFile([string]$specDir, [string]$newVersion) {
    $filePath = Join-Path $specDir $SPECKIT_FILE
    $data = Read-SpecKitFile $specDir
    if (-not $data) { return }
    $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $data.version = $newVersion
    $data.updated = $now
    if (-not $DryRun) {
        $data | ConvertTo-Json -Depth 10 | Set-Content $filePath -Encoding UTF8
    }
}

# ===================================================================
# INSTALL EXECUTION
# ===================================================================

function Invoke-Setup {
    Clear-StepArea
    Write-C ''
    Write-Pad "${C_BOLD}${C_WHITE}Setting up workspace...${C_RESET}" 2
    Write-Pad "${C_DIM}$('_' * 56)${C_RESET}" 2
    Write-C ''

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    $specDir       = Join-Path $script:baseDir $script:specName
    $workspaceFile = Join-Path $script:baseDir "$($script:projectName).code-workspace"

    # -- Spec repo -----------------------------------------------------
    switch ($script:specMode) {
        'template' {
            Write-Task 'Creating spec repo from GitHub template' 'running'
            $fullName = "$($script:specOrg)/$($script:specName)"
            if (-not $DryRun) {
                $visFlag = "--$($script:specVisibility)"
                & gh repo create $fullName --template $TEMPLATE_REPO $visFlag --clone 2>&1 | Out-Null
                $clonedDir = Join-Path (Get-Location) $script:specName
                if ((Test-Path $clonedDir) -and ($clonedDir -ne $specDir)) {
                    Move-Item $clonedDir $specDir -Force
                }
            }
            Write-Task 'Creating spec repo from GitHub template' 'done'
            Write-TaskDetail "${fullName} ($($script:specVisibility))"
        }
        'clone' {
            Write-Task 'Cloning spec template' 'running'
            if (-not $DryRun) {
                Push-Location $script:baseDir
                & git clone $TEMPLATE_URL $script:specName 2>&1 | Out-Null
                $gitDir = Join-Path $specDir '.git'
                Remove-Item $gitDir -Recurse -Force
                Push-Location $specDir
                & git init 2>&1 | Out-Null
                & git add -A 2>&1 | Out-Null
                & git commit -m 'chore: init from spec-kit-template' --quiet 2>&1 | Out-Null
                Pop-Location
                Pop-Location
            }
            Write-Task 'Cloning spec template' 'done'
            Write-TaskDetail $specDir
        }
        'existing' {
            $specDir = $script:specPath
            $script:specName = Split-Path $specDir -Leaf
            Write-Task 'Using existing spec repo' 'done'
            Write-TaskDetail $specDir
        }
    }

    # -- Codebase ------------------------------------------------------
    $codebaseDir = $null
    switch ($script:codebaseMode) {
        'existing' {
            $codebaseDir = $script:codebasePath
            Write-Task 'Linking existing codebase' 'done'
            Write-TaskDetail $codebaseDir
        }
        'clone' {
            $codebaseDir = Join-Path $script:baseDir $script:codebaseName
            Write-Task 'Cloning codebase' 'running'
            if (-not $DryRun) {
                Push-Location $script:baseDir
                & git clone $script:codebaseUrl $script:codebaseName 2>&1 | Out-Null
                Pop-Location
            }
            Write-Task 'Cloning codebase' 'done'
            Write-TaskDetail $codebaseDir
        }
        'empty' {
            $codebaseDir = Join-Path $script:baseDir $script:codebaseName
            Write-Task 'Creating empty codebase' 'running'
            if (-not $DryRun) {
                New-Item -Path $codebaseDir -ItemType Directory -Force | Out-Null
                Push-Location $codebaseDir
                & git init 2>&1 | Out-Null
                Pop-Location
            }
            Write-Task 'Creating empty codebase' 'done'
            Write-TaskDetail $codebaseDir
        }
        'skip' {
            Write-Task 'Codebase' 'skip'
        }
    }

    # -- Workspace file ------------------------------------------------
    Write-Task 'Generating workspace file' 'running'

    $wsParent = Split-Path $workspaceFile -Parent
    $specRel  = Get-RelPath $wsParent $specDir

    $foldersJson = "    { `"name`": `"spec`", `"path`": `"${specRel}`" }"
    $settingsExtra = ''
    if ($codebaseDir) {
        $cbRel = Get-RelPath $wsParent $codebaseDir
        $foldersJson += ",`n    { `"name`": `"codebase`", `"path`": `"${cbRel}`" }"
        $settingsExtra = "`n    `"powershell.cwd`": `"codebase`","
    }

    $wsContent = @"
{
  "folders": [
${foldersJson}
  ],
  "settings": {${settingsExtra}
    "chat.useAgentSkills": true
  },
  "extensions": {
    "recommendations": [
      "GitHub.copilot",
      "GitHub.copilot-chat"
    ]
  }
}
"@

    if (-not $DryRun) {
        $wsContent | Set-Content $workspaceFile -Encoding UTF8
    }
    Write-Task 'Generating workspace file' 'done'
    Write-TaskDetail (Split-Path $workspaceFile -Leaf)

    # -- .speckit control file -----------------------------------------
    Write-Task 'Generating version control file' 'running'
    Write-SpecKitFile $specDir $script:specMode
    Write-Task 'Generating version control file' 'done'
    Write-TaskDetail $SPECKIT_FILE

    # -- Python venv ---------------------------------------------------
    if ($script:installVenv) {
        Write-Task 'Creating Python venv + dependencies' 'running'
        if (-not $DryRun) {
            Push-Location $specDir
            & python -m venv .venv 2>&1 | Out-Null
            $pipExe = Join-Path $specDir '.venv\Scripts\pip.exe'
            if (-not (Test-Path $pipExe)) {
                $pipExe = Join-Path $specDir '.venv/bin/pip'
            }
            & $pipExe install --quiet mkdocs mkdocs-material pyyaml 2>&1 | Out-Null
            $reqFile = Join-Path $specDir 'tools\requirements.txt'
            if (Test-Path $reqFile) {
                & $pipExe install --quiet -r $reqFile 2>&1 | Out-Null
            }
            Pop-Location
        }
        Write-Task 'Creating Python venv + dependencies' 'done'
        Write-TaskDetail 'mkdocs, mkdocs-material, pyyaml'
    } else {
        Write-Task 'Python venv' 'skip'
    }

    # -- VS Code extensions --------------------------------------------
    if ($script:installExtensions) {
        Write-Task 'Installing VS Code extensions' 'running'
        if (-not $DryRun) {
            & code --install-extension GitHub.copilot      --force 2>&1 | Out-Null
            & code --install-extension GitHub.copilot-chat --force 2>&1 | Out-Null
        }
        Write-Task 'Installing VS Code extensions' 'done'
        Write-TaskDetail 'GitHub.copilot, GitHub.copilot-chat'
    } else {
        Write-Task 'VS Code extensions' 'skip'
    }

    # -- Summary -------------------------------------------------------
    Show-InstallSummary $workspaceFile $specDir $codebaseDir

    # -- Open VS Code --------------------------------------------------
    if ($script:openVsCode -and (-not $DryRun)) {
        & code $workspaceFile 2>&1 | Out-Null
    }

    $ErrorActionPreference = $prevEAP
}

# ===================================================================
# INSTALL SUMMARY
# ===================================================================

function Show-InstallSummary([string]$workspaceFile, [string]$specDir, [string]$codebaseDir) {
    if ($script:useTui) {
        Set-CursorAt ($PROGRESS_TOP + $PROGRESS_HEIGHT + 1) 0
    }

    $wsBase   = Split-Path $workspaceFile -Parent
    $wsName   = Split-Path $workspaceFile -Leaf
    $specLeaf = Split-Path $specDir -Leaf

    Write-C ''
    Write-C "  ${C_GREEN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}${C_GREEN}DONE!${C_RESET}                                                      ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}+==============================================================+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_DIM}${wsBase}\${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}    +-- ${C_CYAN}${specLeaf}\${C_RESET}              ${C_DIM}spec${C_RESET}"

    if ($codebaseDir) {
        $cbLeaf = Split-Path $codebaseDir -Leaf
        Write-C "  ${C_GREEN}|${C_RESET}    +-- ${C_BLUE}${cbLeaf}\${C_RESET}                  ${C_DIM}codebase${C_RESET}"
    }

    Write-C "  ${C_GREEN}|${C_RESET}    +-- ${C_WHITE}${wsName}${C_RESET}          ${C_DIM}workspace${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}+--------------------------------------------------------------+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}Next steps:${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}    1. Open the workspace in VS Code"
    Write-C "  ${C_GREEN}|${C_RESET}    2. In Copilot Chat: ${C_CYAN}@spc-spec-director${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}    3. Or run ${C_CYAN}/new-spec${C_RESET} to start the specification"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}+--------------------------------------------------------------+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}SPEC KIT${C_RESET} by ${C_CYAN}LKS Next${C_RESET}                                       ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_DIM}Thank you for using SPEC KIT!${C_RESET}                               ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C ''
}

# ===================================================================
# UPDATE: REMOTE VERSION CHECK
# ===================================================================

function Get-RemoteVersion {
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $remoteVersion = $null

    # Strategy 1: gh api (fast, no clone)
    $hasGh = $null -ne $script:stepResults['gh']
    if ($hasGh) {
        try {
            $raw = & gh api "repos/${TEMPLATE_REPO}/contents/VERSION" --jq '.content' 2>$null
            if ($raw) {
                $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($raw.Trim()))
                $remoteVersion = $decoded.Trim()
            }
        } catch { }
    }

    # Strategy 2: git archive (no full clone)
    if (-not $remoteVersion) {
        try {
            $tmpFile = [System.IO.Path]::GetTempFileName()
            & git archive --remote=$TEMPLATE_URL HEAD VERSION 2>$null | Set-Content $tmpFile -Encoding Byte
            # git archive might not work with GitHub HTTPS, fallback below
        } catch { }
    }

    # Strategy 3: shallow clone (universal fallback)
    if (-not $remoteVersion) {
        try {
            $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "speckit-update-$([guid]::NewGuid().ToString('N').Substring(0,8))"
            & git clone --depth 1 --filter=blob:none --sparse $TEMPLATE_URL $tmpDir 2>$null
            Push-Location $tmpDir
            & git sparse-checkout set VERSION CHANGELOG.md 2>$null
            Pop-Location
            $versionFile = Join-Path $tmpDir 'VERSION'
            if (Test-Path $versionFile) {
                $remoteVersion = (Get-Content $versionFile -Raw).Trim()
            }
            # Keep tmpDir for potential update use
            $script:updateTmpDir = $tmpDir
        } catch { }
    }

    $ErrorActionPreference = $prevEAP
    return $remoteVersion
}

function Get-RemoteChangelog {
    param([string]$fromVersion, [string]$toVersion)
    $changelog = ''

    # Try to read from the clone tmp dir
    if ($script:updateTmpDir) {
        $clFile = Join-Path $script:updateTmpDir 'CHANGELOG.md'
        if (Test-Path $clFile) {
            $changelog = Get-Content $clFile -Raw -Encoding UTF8
        }
    }

    # Try gh api as fallback
    if (-not $changelog -and ($null -ne $script:stepResults['gh'])) {
        try {
            $raw = & gh api "repos/${TEMPLATE_REPO}/contents/CHANGELOG.md" --jq '.content' 2>$null
            if ($raw) {
                $changelog = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($raw.Trim()))
            }
        } catch { }
    }

    if (-not $changelog) { return $null }

    # Extract entries between versions
    $lines = $changelog -split "`n"
    $capture = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^\#\#\s+\[') {
            if ($capture) { break }
            if ($line -notmatch [regex]::Escape($fromVersion)) {
                $capture = $true
            }
        }
        if ($capture) { $result += $line }
    }
    if ($result.Count -eq 0) { return $null }
    return ($result -join "`n")
}

# ===================================================================
# UPDATE: FULL CLONE FOR FILE COPY
# ===================================================================

function Get-UpdateSource {
    # If we already have a sparse clone, convert it to full for managed paths
    if ($script:updateTmpDir -and (Test-Path $script:updateTmpDir)) {
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        Push-Location $script:updateTmpDir
        # Expand sparse checkout to include all managed paths
        & git sparse-checkout set $MANAGED_PATHS 2>$null
        Pop-Location
        $ErrorActionPreference = $prevEAP
        return $script:updateTmpDir
    }

    # Full shallow clone
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "speckit-update-$([guid]::NewGuid().ToString('N').Substring(0,8))"
    & git clone --depth 1 $TEMPLATE_URL $tmpDir 2>$null
    $script:updateTmpDir = $tmpDir
    $ErrorActionPreference = $prevEAP
    return $tmpDir
}

# ===================================================================
# UPDATE: GIT STATUS CHECK
# ===================================================================

function Test-GitClean([string]$specDir) {
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    Push-Location $specDir

    $dirtyFiles = @()
    foreach ($managedPath in $MANAGED_PATHS) {
        $fullPath = Join-Path $specDir $managedPath
        if (Test-Path $fullPath) {
            $status = & git status --porcelain -- $managedPath 2>$null
            if ($status) {
                $dirtyFiles += ($status -split "`n" | ForEach-Object { $_.Trim() })
            }
        }
    }

    Pop-Location
    $ErrorActionPreference = $prevEAP
    return $dirtyFiles
}

# ===================================================================
# UPDATE: APPLY
# ===================================================================

function Invoke-Update([string]$specDir, [string]$sourceDir) {
    Write-C ''
    Write-Pad "${C_BOLD}${C_WHITE}Updating SPEC-KIT...${C_RESET}" 2
    Write-Pad "${C_DIM}$('_' * 56)${C_RESET}" 2
    Write-C ''

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    $stats = @{ updated = 0; added = 0; folders = @() }

    foreach ($managedPath in $MANAGED_PATHS) {
        $src = Join-Path $sourceDir $managedPath
        $dst = Join-Path $specDir $managedPath

        if (-not (Test-Path $src)) { continue }

        $label = $managedPath
        $isDir = (Test-Path $src -PathType Container)

        if ($isDir) {
            Write-Task "Updating ${label}" 'running'
            if (-not $DryRun) {
                if (Test-Path $dst) {
                    Remove-Item $dst -Recurse -Force
                }
                Copy-Item $src $dst -Recurse -Force
            }
            $count = (Get-ChildItem $src -Recurse -File).Count
            $stats.updated += $count
            $stats.folders += $label
            Write-Task "Updating ${label}" 'done'
            Write-TaskDetail "${count} files"
        } else {
            $existed = Test-Path $dst
            Write-Task "Updating ${label}" 'running'
            if (-not $DryRun) {
                $parentDir = Split-Path $dst -Parent
                if (-not (Test-Path $parentDir)) {
                    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
                }
                Copy-Item $src $dst -Force
            }
            if ($existed) { $stats.updated++ } else { $stats.added++ }
            Write-Task "Updating ${label}" 'done'
        }
    }

    $ErrorActionPreference = $prevEAP
    return $stats
}

# ===================================================================
# UPDATE: CLEANUP
# ===================================================================

function Remove-UpdateTemp {
    if ($script:updateTmpDir -and (Test-Path $script:updateTmpDir)) {
        Remove-Item $script:updateTmpDir -Recurse -Force -ErrorAction SilentlyContinue
        $script:updateTmpDir = $null
    }
}

# ===================================================================
# UPDATE SUMMARY
# ===================================================================

function Show-UpdateSummary([string]$fromVersion, [string]$toVersion, $stats) {
    Write-C ''
    Write-C "  ${C_GREEN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}${C_GREEN}Updated: v${fromVersion} -> v${toVersion}${C_RESET}"
    Write-C "  ${C_GREEN}+==============================================================+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}Updated areas:${C_RESET}"

    foreach ($folder in $stats.folders) {
        Write-C "  ${C_GREEN}|${C_RESET}    ${C_CYAN}*${C_RESET} ${folder}"
    }

    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_DIM}Total: $($stats.updated) files updated, $($stats.added) files added${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}+--------------------------------------------------------------+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_YELLOW}!!${C_RESET}  ${C_BOLD}Reload VS Code to apply changes${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}     Ctrl+Shift+P -> ${C_CYAN}Reload Window${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}+--------------------------------------------------------------+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}SPEC KIT${C_RESET} by ${C_CYAN}LKS Next${C_RESET}                                       ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_DIM}Thank you for using SPEC KIT!${C_RESET}                               ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C ''
}

# ===================================================================
# UPDATE FLOW
# ===================================================================

function Invoke-UpdateFlow([string]$specDir) {
    $speckitData = Read-SpecKitFile $specDir
    $localVersion = $speckitData.version

    Write-C ''
    Write-Pad "${C_BOLD}Existing SPEC-KIT project detected${C_RESET}" 2
    Write-Pad "${C_DIM}Installed: v${localVersion}${C_RESET}" 2
    Write-C ''
    Write-Pad "${C_DIM}Checking for updates...${C_RESET}" 2

    # Check prerequisites (minimal: just git)
    $script:stepResults = @{}
    $gitVer = Get-ToolVersion 'git' @('--version')
    if (-not $gitVer) {
        Write-Pad "${C_RED}Git is required. Aborting.${C_RESET}" 2
        exit 1
    }
    $script:stepResults['git'] = $gitVer
    $ghVer = Get-ToolVersion 'gh' @('--version')
    if ($ghVer) { $script:stepResults['gh'] = $ghVer }
    $codeVer = Get-ToolVersion 'code' @('--version')
    if ($codeVer) { $script:stepResults['code'] = $codeVer }

    $remoteVersion = Get-RemoteVersion
    if (-not $remoteVersion) {
        Write-C ''
        Write-Pad "${C_RED}Could not check remote version. Verify internet connection and try again.${C_RESET}" 2
        exit 1
    }

    # --check flag: just report and exit
    if ($Check) {
        if ($remoteVersion -eq $localVersion) {
            Write-Pad "${C_GREEN}[ok] SPEC-KIT is up to date (v${localVersion})${C_RESET}" 2
            Remove-UpdateTemp
            exit 0
        } else {
            Write-Pad "${C_YELLOW}Update available: v${localVersion} -> v${remoteVersion}${C_RESET}" 2
            Remove-UpdateTemp
            exit 1
        }
    }

    if ($remoteVersion -eq $localVersion) {
        Write-C ''
        Write-Pad "${C_GREEN}[ok] SPEC-KIT is up to date (v${localVersion})${C_RESET}" 2
        Write-C ''
        Write-Pad "${C_BOLD}SPEC KIT${C_RESET} by ${C_CYAN}LKS Next${C_RESET}" 2
        Write-Pad "${C_DIM}Thank you for using SPEC KIT!${C_RESET}" 2
        Write-C ''
        if (-not $Update) {
            Remove-UpdateTemp
            return
        }
        Write-Pad "${C_YELLOW}--Update flag set. Forcing re-application of v${localVersion}.${C_RESET}" 2
    } else {
        Write-C ''
        Write-Pad "${C_CYAN}New version available: v${localVersion} -> v${remoteVersion}${C_RESET}" 2
    }

    Write-C ''

    # Interactive update menu
    $updateDone = $false
    while (-not $updateDone) {
        $targetLabel = if ($remoteVersion -eq $localVersion) { "Re-apply v${remoteVersion}" } else { "Update to v${remoteVersion}" }

        $menuOptions = @(
            $targetLabel,
            'View changelog',
            'View files that will change',
            'Skip update'
        )
        $menuHints = @(
            "Updates all managed files: agents, skills, prompts, instructions, docs/kit, tools, and config files. Your spec documents (docs/spec/**) and codebase will NOT be modified.",
            "Shows the changelog entries between your installed version (v${localVersion}) and the available version (v${remoteVersion}).",
            "Shows which files in your project will be overwritten by the update. Only managed SPEC-KIT files are affected.",
            "Exit without making any changes. You can run the bootstrap again later to update."
        )

        $menuChoice = Read-InteractiveChoice -Title 'What would you like to do?' -Options $menuOptions -Hints $menuHints -Default 0

        switch ($menuChoice) {
            0 {
                # UPDATE
                # Check git status
                $dirtyFiles = Test-GitClean $specDir
                if ($dirtyFiles.Count -gt 0) {
                    Write-C ''
                    Write-Pad "${C_YELLOW}!!  You have uncommitted changes in managed files:${C_RESET}" 2
                    foreach ($f in $dirtyFiles | Select-Object -First 10) {
                        Write-Pad "${C_DIM}    ${f}${C_RESET}" 4
                    }
                    if ($dirtyFiles.Count -gt 10) {
                        Write-Pad "${C_DIM}    ... and $($dirtyFiles.Count - 10) more${C_RESET}" 4
                    }
                    Write-C ''
                    Write-Pad "The update will overwrite these files. Make sure your" 2
                    Write-Pad "Git repository is up to date so you can recover if needed." 2
                    Write-C ''

                    $confirmChoice = Read-InteractiveChoice -Title 'How do you want to proceed?' -Options @(
                        'Continue anyway (I can recover with git)',
                        'Abort (I will commit first)'
                    ) -Hints @(
                        'The update will proceed and overwrite the changed files. You can always use git checkout or git stash to recover them later.',
                        'Stops the update so you can commit or stash your changes first. Run the bootstrap again when ready.'
                    ) -Default 1

                    if ($confirmChoice -eq 1) {
                        Write-C ''
                        Write-Pad "${C_DIM}Update cancelled. Commit your changes and try again.${C_RESET}" 2
                        Remove-UpdateTemp
                        return
                    }
                } else {
                    Write-C ''
                    Write-Pad "${C_GREEN}[ok] Working tree is clean -- safe to update.${C_RESET}" 2
                }

                # Get full source
                Write-C ''
                Write-Pad "${C_DIM}Downloading update files...${C_RESET}" 2
                $sourceDir = Get-UpdateSource

                if (-not $sourceDir -or -not (Test-Path $sourceDir)) {
                    Write-Pad "${C_RED}Failed to download update source. Try again.${C_RESET}" 2
                    Remove-UpdateTemp
                    return
                }

                # Apply update
                $stats = Invoke-Update $specDir $sourceDir

                # Update .speckit
                Update-SpecKitFile $specDir $remoteVersion

                # Cleanup
                Remove-UpdateTemp

                # Summary
                Show-UpdateSummary $localVersion $remoteVersion $stats

                # Offer VS Code reload
                if ($null -ne $script:stepResults['code']) {
                    $reloadChoice = Read-InteractiveChoice -Title 'VS Code needs to reload to apply agent/skill changes.' -Options @(
                        'Reload VS Code now (reopens workspace)',
                        'I will reload manually (Ctrl+Shift+P -> Reload Window)'
                    ) -Hints @(
                        'Opens the workspace file which will trigger VS Code to reload and pick up the updated agents, skills, and instructions.',
                        'You will need to manually reload VS Code by pressing Ctrl+Shift+P and typing "Reload Window" to apply the changes.'
                    ) -Default 0

                    if ($reloadChoice -eq 0 -and -not $DryRun) {
                        # Find the workspace file
                        $wsFiles = Get-ChildItem (Split-Path $specDir -Parent) -Filter '*.code-workspace' -File 2>$null
                        if ($wsFiles) {
                            & code $wsFiles[0].FullName --reuse-window 2>&1 | Out-Null
                        }
                    }
                }

                $updateDone = $true
            }
            1 {
                # VIEW CHANGELOG
                Write-C ''
                $clContent = Get-RemoteChangelog $localVersion $remoteVersion
                if ($clContent) {
                    Write-C "  ${C_CYAN}+--- Changelog: v${localVersion} -> v${remoteVersion} ---+${C_RESET}"
                    foreach ($line in ($clContent -split "`n")) {
                        Write-C "  ${C_DIM}|${C_RESET}  ${line}"
                    }
                    Write-C "  ${C_CYAN}+$('-' * 50)+${C_RESET}"
                } else {
                    Write-Pad "${C_DIM}No changelog available. Check the GitHub releases page for details.${C_RESET}" 2
                }
                Read-Continue
                Write-C ''
            }
            2 {
                # VIEW FILES THAT WILL CHANGE
                Write-C ''
                Write-C "  ${C_CYAN}+--- Files managed by SPEC-KIT ---+${C_RESET}"
                foreach ($mp in $MANAGED_PATHS) {
                    $fullPath = Join-Path $specDir $mp
                    if (Test-Path $fullPath -PathType Container) {
                        $fileCount = (Get-ChildItem $fullPath -Recurse -File -ErrorAction SilentlyContinue).Count
                        Write-C "  ${C_DIM}|${C_RESET}  ${C_CYAN}${mp}/${C_RESET}  ${C_DIM}(${fileCount} files)${C_RESET}"
                    } elseif (Test-Path $fullPath) {
                        Write-C "  ${C_DIM}|${C_RESET}  ${mp}"
                    } else {
                        Write-C "  ${C_DIM}|${C_RESET}  ${C_GREEN}+ ${mp}${C_RESET}  ${C_DIM}(new)${C_RESET}"
                    }
                }
                Write-C "  ${C_CYAN}+$('-' * 35)+${C_RESET}"
                Write-C ''
                Write-Pad "${C_DIM}These paths will be overwritten. docs/spec/** is NOT affected.${C_RESET}" 2
                Read-Continue
                Write-C ''
            }
            3 {
                # SKIP
                Write-C ''
                Write-Pad "${C_DIM}Update skipped. Run bootstrap again when ready.${C_RESET}" 2
                Write-C ''
                Remove-UpdateTemp
                $updateDone = $true
            }
        }
    }
}

# ===================================================================
# MODE DETECTION
# ===================================================================

function Find-RunMode {
    # Check if tools/.speckit exists relative to the script location
    $scriptDir = Split-Path $PSCommandPath -Parent
    $specDir   = Split-Path $scriptDir -Parent
    $speckitPath = Join-Path $specDir $SPECKIT_FILE

    if (Test-Path $speckitPath) {
        $script:runMode = 'update'
        return $specDir
    }

    # No .speckit found -> install mode
    $script:runMode = 'install'
    return $null
}

# ===================================================================
# MAIN
# ===================================================================

function Main {
    $script:useTui = Test-TuiSupport
    $script:updateTmpDir = $null

    if ($DryRun) {
        Write-C "${C_YELLOW}[DRY RUN] No files will be created or modified.${C_RESET}"
        Write-C ''
    }

    Show-Header

    $specDir = Find-RunMode

    if ($script:runMode -eq 'update') {
        Invoke-UpdateFlow $specDir
    } else {
        Test-Prerequisites
        Get-ProjectConfig
        Get-SpecConfig
        Get-CodebaseConfig
        Get-ExtrasConfig
        Invoke-Setup
    }
}

Main
