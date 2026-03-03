<#
.SYNOPSIS
    Spec Kit - Workspace Bootstrap (Windows)
.DESCRIPTION
    Sets up a complete spec-kit workspace: creates the spec project from the
    GitHub template, links (or creates) a codebase project, generates the
    VS Code .code-workspace file, and optionally installs Python/mkdocs deps.
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
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ===================================================================
# CONSTANTS
# ===================================================================

$TEMPLATE_REPO  = 'lksnext-ai-lab/spec-kit-template'
$TEMPLATE_URL   = "https://github.com/${TEMPLATE_REPO}.git"
$SCRIPT_VERSION = '1.0.0'

# ESC character for ANSI — works in PowerShell 5.1+
$ESC = [char]0x1b

# TUI geometry
$HEADER_HEIGHT    = 14
$STEP_AREA_HEIGHT = 14
$PROGRESS_HEIGHT  = 4
$STEP_AREA_TOP    = $HEADER_HEIGHT
$PROGRESS_TOP     = $HEADER_HEIGHT + $STEP_AREA_HEIGHT

# Colors
$C_RESET   = "${ESC}[0m"
$C_BOLD    = "${ESC}[1m"
$C_DIM     = "${ESC}[2m"
$C_GREEN   = "${ESC}[32m"
$C_YELLOW  = "${ESC}[33m"
$C_CYAN    = "${ESC}[36m"
$C_RED     = "${ESC}[31m"
$C_BLUE    = "${ESC}[34m"
$C_WHITE   = "${ESC}[97m"
$C_CLR_LN  = "${ESC}[K"

# State
$script:useTui       = $false
$script:stepResults  = @{}
$script:totalSteps   = 5
$script:currentStep  = 0
$script:projectName  = ''
$script:specName     = ''
$script:baseDir      = ''
$script:specMode     = ''
$script:specOrg      = ''
$script:specVisibility = ''
$script:specPath     = ''
$script:codebaseMode = ''
$script:codebasePath = ''
$script:codebaseUrl  = ''
$script:codebaseName = ''
$script:installVenv  = $false
$script:installExtensions = $false
$script:openVsCode   = $false

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
    if (-not $script:useTui) { Write-Host ''; return }
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

function Show-Header {
    if ($script:useTui) { Clear-Host }

    Write-C ''
    Write-C "  ${C_CYAN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_BOLD}${C_WHITE}  ___  ___  ___  ___    _  _ ___ _____${C_RESET}                       ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_WHITE} / __|/ _ \/ __|/ __|  | |/ /_ _|_   _|${C_RESET}                      ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_WHITE} \__ \ __/ (__| (__   |   < | |  | |${C_RESET}                        ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_WHITE} |___/\___|\___|\___|  |_|\_\___| |_|${C_RESET}                       ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}  ${C_DIM}Workspace Bootstrap${C_RESET}                              ${C_DIM}v${SCRIPT_VERSION}${C_RESET}  ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}|${C_RESET}                                                              ${C_CYAN}|${C_RESET}"
    Write-C "  ${C_CYAN}${C_BOLD}+==============================================================+${C_RESET}"
    # Pad header to fixed height
    $headerLines = 12
    for ($i = $headerLines; $i -lt $HEADER_HEIGHT; $i++) { Write-C '' }
}

# ===================================================================
# PROGRESS BAR
# ===================================================================

function Show-ProgressBar {
    if (-not $script:useTui) { return }
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

function Read-Choice([string]$prompt, [string[]]$options, [int]$default) {
    for ($i = 0; $i -lt $options.Count; $i++) {
        $num = $i + 1
        $marker = ''
        if ($num -eq $default) { $marker = " ${C_GREEN}<- default${C_RESET}" }
        Write-Pad "${C_BOLD}[${num}]${C_RESET} $($options[$i])${marker}" 4
    }
    Write-C ''
    Write-Host "  ${C_CYAN}>${C_RESET} ${prompt} ${C_DIM}[${default}]${C_RESET}: " -NoNewline
    $val = Read-Host
    if ([string]::IsNullOrWhiteSpace($val)) { return $default }
    $num = 0
    if ([int]::TryParse($val, [ref]$num) -and $num -ge 1 -and $num -le $options.Count) {
        return $num
    }
    Write-Pad "${C_RED}Invalid choice.${C_RESET}" 2
    return (Read-Choice $prompt $options $default)
}

function Read-YesNo([string]$prompt, [bool]$default) {
    $hint = 'y/N'
    if ($default) { $hint = 'Y/n' }
    Write-Host "  ${C_CYAN}>${C_RESET} ${prompt} ${C_DIM}[${hint}]${C_RESET}: " -NoNewline
    $val = Read-Host
    if ([string]::IsNullOrWhiteSpace($val)) { return $default }
    return ($val -match '^[yYsS]')
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

    $script:currentStep = 1
    Show-ProgressBar
    Start-Sleep -Milliseconds 500
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
    if ($hasGh) {
        $options += 'Create from GitHub template (requires gh CLI)'
    } else {
        $options += 'Create from GitHub template (gh not found)'
    }
    $options += 'Clone template locally (no GitHub repo)'
    $options += 'I already have the spec cloned'

    $defaultChoice = 2
    if ($hasGh) { $defaultChoice = 1 }
    $choice = Read-Choice 'Choose' $options $defaultChoice

    switch ($choice) {
        1 {
            if (-not $hasGh) {
                Write-Pad "${C_YELLOW}gh CLI not found. Falling back to clone.${C_RESET}" 4
                $script:specMode = 'clone'
            } else {
                Write-C ''
                $org = Read-Value 'GitHub org/user for the new repo' 'lksnext-ai-lab'
                $vis = Read-Choice 'Visibility' @('Private', 'Public') 1
                $script:specMode  = 'template'
                $script:specOrg   = $org
                if ($vis -eq 1) {
                    $script:specVisibility = 'private'
                } else {
                    $script:specVisibility = 'public'
                }
            }
        }
        2 { $script:specMode = 'clone' }
        3 {
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
    $choice = Read-Choice 'Choose' $options 1

    switch ($choice) {
        1 {
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
        2 {
            Write-C ''
            $url = Read-Value 'Git clone URL' '' -Required
            $dirName = Read-Value 'Local folder name' $script:projectName
            $script:codebaseMode = 'clone'
            $script:codebaseUrl  = $url
            $script:codebaseName = $dirName
        }
        3 {
            $script:codebaseMode = 'empty'
            $script:codebaseName = $script:projectName
        }
        4 {
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
# EXECUTION
# ===================================================================

function Get-RelPath([string]$from, [string]$to) {
    # PS 5.1 / .NET Framework compat — [IO.Path]::GetRelativePath unavailable
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

function Invoke-Setup {
    Clear-StepArea
    Write-C ''
    Write-Pad "${C_BOLD}${C_WHITE}Setting up workspace...${C_RESET}" 2
    Write-Pad "${C_DIM}$('_' * 56)${C_RESET}" 2
    Write-C ''

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
    Show-Summary $workspaceFile $specDir $codebaseDir

    # -- Open VS Code --------------------------------------------------
    if ($script:openVsCode -and (-not $DryRun)) {
        & code $workspaceFile 2>&1 | Out-Null
    }
}

# ===================================================================
# SUMMARY
# ===================================================================

function Show-Summary([string]$workspaceFile, [string]$specDir, [string]$codebaseDir) {
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
    Write-C "  ${C_GREEN}+==============================================================+${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}  ${C_BOLD}Next steps:${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}    1. Open the workspace in VS Code"
    Write-C "  ${C_GREEN}|${C_RESET}    2. In Copilot Chat: ${C_CYAN}@spc-spec-director${C_RESET}"
    Write-C "  ${C_GREEN}|${C_RESET}    3. Or run ${C_CYAN}/new-spec${C_RESET} to start the specification"
    Write-C "  ${C_GREEN}|${C_RESET}                                                              ${C_GREEN}|${C_RESET}"
    Write-C "  ${C_GREEN}${C_BOLD}+==============================================================+${C_RESET}"
    Write-C ''
}

# ===================================================================
# MAIN
# ===================================================================

function Main {
    $script:useTui = Test-TuiSupport

    if ($DryRun) {
        Write-C "${C_YELLOW}[DRY RUN] No files will be created or modified.${C_RESET}"
        Write-C ''
    }

    Show-Header
    Test-Prerequisites
    Get-ProjectConfig
    Get-SpecConfig
    Get-CodebaseConfig
    Get-ExtrasConfig
    Invoke-Setup
}

Main
