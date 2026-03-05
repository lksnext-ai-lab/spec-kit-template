#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  Spec Kit — Workspace Bootstrap & Update (Unix)
#
#  First run  : wizard that creates the spec project from the
#               GitHub template, links (or creates) a codebase
#               project, generates the VS Code .code-workspace
#               file, and optionally installs Python/mkdocs deps.
#  Subsequent : detects the existing SPEC-KIT installation via
#               tools/.speckit, checks for upstream updates, and
#               offers an interactive update flow.
#
#  Requirements: bash 4+, git.
#  Optional: gh (GitHub CLI), python3, code (VS Code CLI).
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

TEMPLATE_REPO="lksnext-ai-lab/spec-kit-template"
TEMPLATE_URL="https://github.com/$TEMPLATE_REPO.git"
SCRIPT_VERSION="2.4.0" # x-release-please-version

SPECKIT_FILE="tools/.speckit"

MANAGED_PATHS=(
    ".github/agents"
    ".github/instructions"
    ".github/prompts"
    ".github/skills"
    ".github/workflows"
    ".github/copilot-instructions.md"
    ".github/CODEOWNERS"
    ".github/PULL_REQUEST_TEMPLATE.md"
    "docs/kit"
    "tools"
    "VERSION"
    "mkdocs.yml"
    "CONTRIBUTING.md"
    "DCO.txt"
    "LICENSE"
    "NOTICE"
    "TRADEMARKS.md"
)

# ── Flags ──────────────────────────────────────────────────
WORKSPACE_ONLY=false
NO_VENV=false
NO_OPEN=false
YES=false
DRY_RUN=false
CHECK=false
UPDATE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace-only) WORKSPACE_ONLY=true ;;
        --no-venv)        NO_VENV=true ;;
        --no-open)        NO_OPEN=true ;;
        --yes)            YES=true ;;
        --dry-run)        DRY_RUN=true ;;
        --check)          CHECK=true ;;
        --update)         UPDATE=true ;;
        -h|--help)
            echo "Usage: bootstrap.sh [--workspace-only] [--no-venv] [--no-open] [--yes] [--dry-run] [--check] [--update]"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# ── TUI geometry ──────────────────────────────────────────
HEADER_HEIGHT=14
STEP_AREA_HEIGHT=14
PROGRESS_HEIGHT=4
STEP_AREA_TOP=$HEADER_HEIGHT
PROGRESS_TOP=$(( HEADER_HEIGHT + STEP_AREA_HEIGHT ))

# ── Colors ────────────────────────────────────────────────
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_CYAN='\033[38;5;208m'  # LKS brand orange
C_RED='\033[31m'
C_BLUE='\033[34m'
C_WHITE='\033[97m'
C_HIDE='\033[?25l'
C_SHOW='\033[?25h'

# ── State ─────────────────────────────────────────────────
USE_TUI=false
CURRENT_STEP=0
TOTAL_STEPS=5

HAS_GIT="" ; HAS_CODE="" ; HAS_GH="" ; HAS_PYTHON=""

PROJECT_NAME="" ; SPEC_NAME="" ; BASE_DIR=""
SPEC_MODE="" ; SPEC_ORG="" ; SPEC_VIS="" ; SPEC_PATH=""
CB_MODE="" ; CB_NAME="" ; CB_PATH="" ; CB_URL=""
INSTALL_VENV=false ; INSTALL_EXT=false ; OPEN_VSCODE=false
RUN_MODE="install"
HEADER_ANIMATED=false
UPDATE_TMP_DIR=""

# Update stats (global for summary)
UPDATED_COUNT=0
ADDED_COUNT=0
UPDATED_FOLDERS=()

STEP_LABELS=("Prerequisites" "Project" "Spec repo" "Codebase" "Extras")

# ═══════════════════════════════════════════════════════════════
# TUI HELPERS
# ═══════════════════════════════════════════════════════════════

test_tui_support() {
    [[ -t 1 ]] || { echo false; return; }
    local rows
    rows=$(tput lines 2>/dev/null || echo 0)
    local min=$(( HEADER_HEIGHT + STEP_AREA_HEIGHT + PROGRESS_HEIGHT + 2 ))
    [[ $rows -ge $min ]] && echo true || echo false
}

cursor_at() {
    $USE_TUI && tput cup "$1" "${2:-0}"
}

clear_step_area() {
    if ! $USE_TUI; then
        clear
        show_header
        return
    fi
    cursor_at "$STEP_AREA_TOP" 0
    for (( i=0; i<STEP_AREA_HEIGHT; i++ )); do
        printf '\033[K\n'
    done
    cursor_at "$STEP_AREA_TOP" 0
}

w_line() {
    local text="$1" color="${2:-}"
    if [[ -n "$color" ]]; then
        printf "${color}%s${C_RESET}\n" "$text"
    else
        echo "$text"
    fi
}

w_pad() {
    local text="$1" indent="${2:-2}" color="${3:-}"
    local pad
    pad=$(printf '%*s' "$indent" '')
    w_line "${pad}${text}" "$color"
}

# ═══════════════════════════════════════════════════════════════
# HEADER
# ═══════════════════════════════════════════════════════════════

show_boot_animation() {
    printf "${C_HIDE}"
    clear

    # Raw logo lines (62 chars each)
    local -a logo=(
        '      _____ ____  ___________     __ __ __________            '
        '     / ___// __ \/ ____/ ___/    / //_//  _/_  __/            '
        '     \__ \/ /_/ / __/ / /       / ,<   / /  / /               '
        '    ___/ / ____/ /___/ /___    / /| |_/ /  / /                '
        '   /____/_/   /_____/\____/   /_/ |_/___/ /_/                 '
    )
    local subtitle='Workspace Bootstrap'
    local byline='by LKS Next'
    local pool='@#$%&*=+~:;!?<>{}[]|^/\-_.'
    local pool_len=${#pool}
    local border
    border=$(printf "  ${C_CYAN}${C_BOLD}╔══════════════════════════════════════════════════════════════╗${C_RESET}")
    local empty_row
    empty_row=$(printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}")

    # Draw static frame once
    echo ''                                  # row 0
    printf '%b\n' "$border"                  # row 1
    printf '%b\n' "$empty_row"               # row 2
    # Logo placeholder rows 3-7
    for (( r=0; r<5; r++ )); do
        printf "  ${C_CYAN}║${C_RESET}%62s${C_CYAN}║${C_RESET}\n" ' '
    done
    printf '%b\n' "$empty_row"               # row 8
    # Subtitle + byline placeholder rows 9-10
    printf "  ${C_CYAN}║${C_RESET}%62s${C_CYAN}║${C_RESET}\n" ' '
    printf "  ${C_CYAN}║${C_RESET}%62s${C_CYAN}║${C_RESET}\n" ' '
    printf '%b\n' "$empty_row"               # row 11
    printf '%b\n' "$border"                  # row 12

    local logo_start_row=3
    local sub_row=9
    local by_row=10

    # ── Phase 1: Scramble resolve — 12 frames ─────────────────────
    local -a ratios=(0 0 5 10 18 28 40 52 65 78 88 95)
    for pct in "${ratios[@]}"; do
        for (( r=0; r<5; r++ )); do
            tput cup $(( logo_start_row + r )) 4
            local line="${logo[$r]}"
            local len=${#line}
            local output=''
            for (( i=0; i<len; i++ )); do
                local ch="${line:$i:1}"
                if [[ "$ch" == ' ' ]]; then
                    output+=' '
                elif (( RANDOM % 100 < pct )); then
                    output+="$ch"
                else
                    output+="${pool:$(( RANDOM % pool_len )):1}"
                fi
            done
            printf "${C_DIM}%s${C_RESET}" "$output"
        done
        sleep 0.09
    done

    # ── Phase 2: Full logo revealed with bold color ───────────────
    for (( r=0; r<5; r++ )); do
        tput cup $(( logo_start_row + r )) 4
        local raw="${logo[$r]}"
        local spec_part="${raw:0:30}"
        local kit_part="${raw:30}"
        printf "${C_BOLD}${C_WHITE}%s${C_RESET}${C_BOLD}${C_CYAN}%s${C_RESET}" "$spec_part" "$kit_part"
    done
    sleep 0.2

    # ── Phase 3: Typewriter subtitle ──────────────────────────────
    tput cup "$sub_row" 6
    for (( i=0; i<${#subtitle}; i++ )); do
        printf "${C_DIM}%s${C_RESET}" "${subtitle:$i:1}"
        sleep 0.025
    done
    # Version number — appears instantly
    local ver_text="v${SCRIPT_VERSION}"
    local ver_col=$(( 4 + 62 - ${#ver_text} - 4 ))
    tput cup "$sub_row" "$ver_col"
    printf "${C_DIM}%s${C_RESET}" "$ver_text"
    sleep 0.1

    # ── Phase 4: Typewriter byline ────────────────────────────────
    tput cup "$by_row" 6
    for (( i=0; i<${#byline}; i++ )); do
        printf "${C_DIM}%s${C_RESET}" "${byline:$i:1}"
        sleep 0.03
    done

    sleep 0.4

    # Move cursor past the frame
    tput cup 13 0
    printf "${C_SHOW}"
}

show_header() {
    # Animated intro only on first display when TUI is active
    if ! $HEADER_ANIMATED && $USE_TUI; then
        HEADER_ANIMATED=true
        show_boot_animation
        # Animation already drew the full header — pad to fixed height
        local header_lines=13
        for (( i=header_lines; i<HEADER_HEIGHT; i++ )); do echo ''; done
        return
    fi
    $USE_TUI && clear

    echo ''
    printf "  ${C_CYAN}${C_BOLD}╔══════════════════════════════════════════════════════════════╗${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}      ${C_BOLD}${C_WHITE}_____ ____  ___________${C_RESET}     ${C_BOLD}${C_CYAN}__ __ __________${C_RESET}            ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}     ${C_BOLD}${C_WHITE}/ ___// __ \\/ ____/ ___/${C_RESET}    ${C_BOLD}${C_CYAN}/ //_//  _/_  __/${C_RESET}            ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}     ${C_BOLD}${C_WHITE}\\__ \\/ /_/ / __/ / /${C_RESET}       ${C_BOLD}${C_CYAN}/ ,<   / /  / /${C_RESET}               ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}    ${C_BOLD}${C_WHITE}___/ / ____/ /___/ /___${C_RESET}    ${C_BOLD}${C_CYAN}/ /| |_/ /  / /${C_RESET}                ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}   ${C_BOLD}${C_WHITE}/____/_/   /_____/\\____/${C_RESET}   ${C_BOLD}${C_CYAN}/_/ |_/___/ /_/${C_RESET}                 ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}  ${C_DIM}Workspace Bootstrap${C_RESET}                              ${C_DIM}v${SCRIPT_VERSION}${C_RESET}     ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}  ${C_DIM}by LKS Next${C_RESET}                                                   ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}${C_BOLD}╚══════════════════════════════════════════════════════════════╝${C_RESET}\n"
    # Pad header to fixed height
    local header_lines=13
    for (( i=header_lines; i<HEADER_HEIGHT; i++ )); do echo ''; done
}

# ═══════════════════════════════════════════════════════════════
# PROGRESS BAR
# ═══════════════════════════════════════════════════════════════

show_progress_bar() {
    $USE_TUI || return
    printf '\033[s'

    cursor_at "$PROGRESS_TOP" 0
    for (( i=0; i<PROGRESS_HEIGHT; i++ )); do printf '\033[K\n'; done
    cursor_at "$PROGRESS_TOP" 0

    local pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
    local filled=$(( CURRENT_STEP * 40 / TOTAL_STEPS ))
    local empty=$(( 40 - filled ))
    local bar=""
    for (( i=0; i<filled; i++ )); do bar+="━"; done
    for (( i=0; i<empty; i++ )); do bar+="○"; done
    printf "  ${C_DIM}Step %d/%d${C_RESET} ${C_CYAN}%s${C_RESET}  ${C_BOLD}%d%%${C_RESET}\n" \
        "$CURRENT_STEP" "$TOTAL_STEPS" "$bar" "$pct"
    echo ''

    local line='  '
    for (( i=0; i<${#STEP_LABELS[@]}; i++ )); do
        local label="${STEP_LABELS[$i]}"
        if (( i < CURRENT_STEP )); then
            line+=$(printf "${C_GREEN}✓ %s${C_RESET}  " "$label")
        elif (( i == CURRENT_STEP )); then
            line+=$(printf "${C_CYAN}${C_BOLD}▶ %s${C_RESET}  " "$label")
        else
            line+=$(printf "${C_DIM}○ %s${C_RESET}  " "$label")
        fi
    done
    printf '%b\n' "$line"

    printf '\033[u'
}

# ═══════════════════════════════════════════════════════════════
# STEP DISPLAY
# ═══════════════════════════════════════════════════════════════

show_step_header() {
    local title="$1"
    clear_step_area
    local num=$(( CURRENT_STEP + 1 ))
    echo ''
    w_pad "$(printf "${C_BOLD}${C_WHITE}STEP %d / %d — %s${C_RESET}" "$num" "$TOTAL_STEPS" "$title")"
    local sep=""
    for (( i=0; i<56; i++ )); do sep+="─"; done
    w_pad "$(printf "${C_DIM}%s${C_RESET}" "$sep")"
    echo ''
}

# ═══════════════════════════════════════════════════════════════
# INPUT HELPERS
# ═══════════════════════════════════════════════════════════════

read_value() {
    local prompt="$1" default="${2:-}" required="${3:-false}"
    local display_default=""
    [[ -n "$default" ]] && display_default=" $(printf "${C_DIM}[%s]${C_RESET}" "$default")"
    printf "  ${C_CYAN}▸${C_RESET} %b%b: " "$prompt" "$display_default"
    local val
    read -r val
    val="${val## }" ; val="${val%% }"
    if [[ -z "$val" ]]; then
        if [[ -n "$default" ]]; then echo "$default"; return; fi
        if [[ "$required" == "true" ]]; then
            w_pad "Value required." 2 "$C_RED"
            read_value "$prompt" "$default" "$required"
            return
        fi
        echo ''
    else
        echo "$val"
    fi
}

read_yesno() {
    local prompt="$1" default="${2:-true}"
    local hint
    [[ "$default" == "true" ]] && hint="Y/n" || hint="y/N"
    printf "  ${C_CYAN}▸${C_RESET} %s ${C_DIM}[%s]${C_RESET}: " "$prompt" "$hint"
    local val
    read -r val
    if [[ -z "$val" ]]; then
        [[ "$default" == "true" ]] && return 0 || return 1
    fi
    [[ "$val" =~ ^[yYsS] ]] && return 0 || return 1
}

read_continue() {
    echo ''
    printf "  ${C_DIM}Press Enter to continue...${C_RESET}"
    read -r _
}

# ═══════════════════════════════════════════════════════════════
# INTERACTIVE SELECTOR (arrow keys + context hints)
# ═══════════════════════════════════════════════════════════════

# Usage: read_interactive_choice "Title" default_idx opt1 opt2 ... -- hint1 hint2 ...
# Returns 0-based index via stdout
read_interactive_choice() {
    local title="$1"
    local default_idx="${2:-0}"
    shift 2

    local options=()
    local hints=()
    local reading_hints=false

    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--" ]]; then
            reading_hints=true
            shift
            continue
        fi
        if $reading_hints; then
            hints+=("$1")
        else
            options+=("$1")
        fi
        shift
    done

    local opt_count=${#options[@]}
    local selected=$default_idx

    # Fallback if not a terminal
    if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
        for (( i=0; i<opt_count; i++ )); do
            local num=$(( i + 1 ))
            local marker=""
            (( i == default_idx )) && marker=" $(printf "${C_GREEN}<- default${C_RESET}")"
            w_pad "$(printf "${C_BOLD}[%d]${C_RESET} %s%b" "$num" "${options[$i]}" "$marker")" 4
        done
        echo ''
        local def_num=$(( default_idx + 1 ))
        printf "  ${C_CYAN}▸${C_RESET} Choose ${C_DIM}[%d]${C_RESET}: " "$def_num"
        local val
        read -r val
        if [[ -z "$val" ]]; then echo "$default_idx"; return; fi
        if [[ "$val" =~ ^[0-9]+$ ]] && (( val >= 1 && val <= opt_count )); then
            echo $(( val - 1 ))
            return
        fi
        echo "$default_idx"
        return
    fi

    local hint_box_height=6
    local total_lines=$(( 1 + 1 + opt_count + 1 + hint_box_height + 1 + 1 ))

    # Get current cursor row
    _get_cursor_row() {
        local old_settings
        old_settings=$(stty -g)
        stty raw -echo min 0
        printf '\033[6n'
        local response=""
        while true; do
            local char
            read -rsn1 -t 1 char || break
            response+="$char"
            [[ "$char" == "R" ]] && break
        done
        stty "$old_settings"
        response="${response#*[}"
        echo "${response%;*}"
    }

    # Hide cursor
    printf "${C_HIDE}"
    trap 'printf "${C_SHOW}"' RETURN

    local start_row
    start_row=$(_get_cursor_row)

    while true; do
        # Move to start position
        tput cup $(( start_row - 1 )) 0 2>/dev/null || printf "\033[${start_row};1H"

        # Title
        w_pad "$(printf "${C_BOLD}${C_WHITE}%s${C_RESET}" "$title")"
        echo ''

        # Options
        for (( i=0; i<opt_count; i++ )); do
            if (( i == selected )); then
                w_pad "$(printf "${C_CYAN}${C_BOLD}--> * %s${C_RESET}" "${options[$i]}")" 4
            else
                w_pad "$(printf "${C_DIM}    o %s${C_RESET}" "${options[$i]}")" 4
            fi
        done

        echo ''

        # Hint box
        local hint=""
        if (( selected < ${#hints[@]} )); then
            hint="${hints[$selected]}"
        fi
        local box_width=55
        local border=""
        for (( b=0; b<box_width; b++ )); do border+="-"; done
        w_pad "$(printf "${C_DIM}+%s+${C_RESET}" "$border")" 4

        # Wrap hint text
        local hint_lines=()
        if [[ -n "$hint" ]]; then
            local line=""
            for word in $hint; do
                if (( ${#line} + ${#word} + 1 > box_width - 4 )); then
                    hint_lines+=("$line")
                    line="$word"
                else
                    [[ -n "$line" ]] && line+=" "
                    line+="$word"
                fi
            done
            [[ -n "$line" ]] && hint_lines+=("$line")
        fi

        while (( ${#hint_lines[@]} < 4 )); do
            hint_lines+=("")
        done
        for (( i=0; i<4; i++ )); do
            local content="${hint_lines[$i]}"
            local pad_len=$(( box_width - 2 - ${#content} ))
            (( pad_len < 0 )) && pad_len=0
            local padding=""
            for (( j=0; j<pad_len; j++ )); do padding+=" "; done
            printf "    ${C_DIM}|${C_RESET}  %s%s${C_DIM}|${C_RESET}\n" "$content" "$padding"
        done
        w_pad "$(printf "${C_DIM}+%s+${C_RESET}" "$border")" 4

        echo ''

        local pos="$(( selected + 1 ))/${opt_count}"
        printf "  ${C_DIM}Up/Down Navigate   Enter Select${C_RESET}                       ${C_DIM}%s${C_RESET}\n" "$pos"

        # Read key
        local key
        read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 -t 0.1 key
                case "$key" in
                    '[A') (( selected > 0 )) && (( selected-- )) || true ;;
                    '[B') (( selected < opt_count - 1 )) && (( selected++ )) || true ;;
                esac
                ;;
            '') # Enter
                printf "${C_SHOW}"
                tput cup $(( start_row - 1 )) 0 2>/dev/null || printf "\033[${start_row};1H"
                for (( i=0; i<total_lines; i++ )); do printf '\033[K\n'; done
                tput cup $(( start_row - 1 )) 0 2>/dev/null || printf "\033[${start_row};1H"
                w_pad "$(printf "${C_GREEN}✓${C_RESET} %s" "${options[$selected]}")" 4
                echo "$selected"
                return
                ;;
        esac

        # Clear area for redraw
        tput cup $(( start_row - 1 )) 0 2>/dev/null || printf "\033[${start_row};1H"
        for (( i=0; i<total_lines; i++ )); do printf '\033[K\n'; done
    done
}

# ═══════════════════════════════════════════════════════════════
# PREREQUISITE CHECKS
# ═══════════════════════════════════════════════════════════════

get_tool_version() {
    local cmd="$1"; shift
    if command -v "$cmd" &>/dev/null; then
        local out
        out=$("$cmd" "$@" 2>&1 | head -1)
        echo "$out" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
    else
        echo ''
    fi
}

test_prerequisites() {
    CURRENT_STEP=0
    show_step_header 'Checking prerequisites'
    show_progress_bar

    local all_good=true

    HAS_GIT=$(get_tool_version git --version)
    if [[ -n "$HAS_GIT" ]]; then
        w_pad "$(printf "${C_GREEN}✓${C_RESET} Git ${C_DIM}%s${C_RESET}" "$HAS_GIT")" 4
    else
        w_pad "$(printf "${C_RED}✗ Git — REQUIRED (install and retry)${C_RESET}")" 4
        all_good=false
    fi

    HAS_CODE=$(get_tool_version code --version)
    if [[ -n "$HAS_CODE" ]]; then
        w_pad "$(printf "${C_GREEN}✓${C_RESET} VS Code ${C_DIM}%s${C_RESET}" "$HAS_CODE")" 4
    else
        w_pad "$(printf "${C_YELLOW}○ VS Code — not found (optional)${C_RESET}")" 4
    fi

    HAS_GH=$(get_tool_version gh --version)
    if [[ -n "$HAS_GH" ]]; then
        w_pad "$(printf "${C_GREEN}✓${C_RESET} GitHub CLI ${C_DIM}%s${C_RESET}" "$HAS_GH")" 4
    else
        w_pad "$(printf "${C_YELLOW}○ GitHub CLI — not found (optional)${C_RESET}")" 4
    fi

    HAS_PYTHON=$(get_tool_version python3 --version)
    [[ -z "$HAS_PYTHON" ]] && HAS_PYTHON=$(get_tool_version python --version)
    if [[ -n "$HAS_PYTHON" ]]; then
        w_pad "$(printf "${C_GREEN}✓${C_RESET} Python ${C_DIM}%s${C_RESET}" "$HAS_PYTHON")" 4
    else
        w_pad "$(printf "${C_YELLOW}○ Python — not found (optional)${C_RESET}")" 4
    fi

    echo ''
    if ! $all_good; then
        w_pad "$(printf "${C_RED}Aborting: missing required tools.${C_RESET}")"
        exit 1
    fi

    w_pad "$(printf "${C_GREEN}All required tools found.${C_RESET}")" 4
    read_continue

    CURRENT_STEP=1
    show_progress_bar
}

# ═══════════════════════════════════════════════════════════════
# STEP 1 — PROJECT NAME & LOCATION
# ═══════════════════════════════════════════════════════════════

get_project_config() {
    show_step_header 'Project name & location'
    show_progress_bar

    PROJECT_NAME=$(read_value 'Project name (e.g. mi-app)' '' true)
    local slug
    slug=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g; s/^-//; s/-$//')
    if [[ "$slug" != "$PROJECT_NAME" ]]; then
        w_pad "$(printf "Normalized to: ${C_BOLD}%s${C_RESET}" "$slug")" 4
    fi
    PROJECT_NAME="$slug"
    SPEC_NAME="spec-$slug"

    echo ''
    BASE_DIR=$(read_value 'Base directory' "$(pwd)")
    if [[ ! -d "$BASE_DIR" ]]; then
        if read_yesno "Directory '$BASE_DIR' does not exist. Create it?"; then
            $DRY_RUN || mkdir -p "$BASE_DIR"
            w_pad "$(printf "${C_GREEN}✓${C_RESET} Created %s" "$BASE_DIR")" 4
        else
            w_pad "$(printf "${C_RED}Aborting.${C_RESET}")"
            exit 1
        fi
    fi
    BASE_DIR=$(cd "$BASE_DIR" && pwd)

    CURRENT_STEP=2
    show_progress_bar
    sleep 0.3
}

# ═══════════════════════════════════════════════════════════════
# STEP 2 — SPEC REPOSITORY
# ═══════════════════════════════════════════════════════════════

get_spec_config() {
    show_step_header 'Spec repository'
    show_progress_bar

    local gh_label gh_hint default_choice
    if [[ -n "$HAS_GH" ]]; then
        gh_label="Create from GitHub template"
        gh_hint="Creates a new private/public repo in your GitHub org using the spec-kit-template. Requires the GitHub CLI (gh) to be installed and authenticated."
        default_choice=1
    else
        gh_label="Create from GitHub template (gh not found)"
        gh_hint="Requires the GitHub CLI (gh) which was not found. Install gh and authenticate first, then re-run the bootstrap."
        default_choice=1
    fi

    local choice
    choice=$(read_interactive_choice \
        "How do you want to set up the spec repository?" \
        "$default_choice" \
        "$gh_label" \
        "Clone template locally" \
        "Use existing spec repo" \
        -- \
        "$gh_hint" \
        "Clones the spec-kit-template repo and reinitializes git history. You get a fresh local repo that you can push to any remote later. Best for GitLab, Bitbucket, or Azure DevOps." \
        "Point to a spec repo already cloned on your machine. The bootstrap will link it to the workspace without modifying it.")

    case "$choice" in
        0)
            if [[ -z "$HAS_GH" ]]; then
                w_pad "$(printf "${C_YELLOW}gh CLI not found. Falling back to clone.${C_RESET}")"
                SPEC_MODE='clone'
            else
                echo ''
                SPEC_ORG=$(read_value 'GitHub org/user for the new repo' 'lksnext-ai-lab')
                local vis
                vis=$(read_interactive_choice \
                    "Repository visibility" \
                    0 \
                    "Private" "Public" \
                    -- \
                    "The repository will only be visible to you and collaborators you explicitly grant access to." \
                    "The repository will be visible to everyone on the internet. Choose this for open-source projects.")
                SPEC_MODE='template'
                [[ "$vis" == "0" ]] && SPEC_VIS='private' || SPEC_VIS='public'
            fi
            ;;
        1) SPEC_MODE='clone' ;;
        2)
            echo ''
            SPEC_PATH=$(read_value 'Path to existing spec repo' '' true)
            if [[ ! -d "$SPEC_PATH/docs/spec" ]]; then
                w_pad "$(printf "${C_YELLOW}Warning: docs/spec/ not found in '%s'. Continuing anyway.${C_RESET}" "$SPEC_PATH")"
            fi
            SPEC_MODE='existing'
            ;;
    esac

    CURRENT_STEP=3
    show_progress_bar
    sleep 0.3
}

# ═══════════════════════════════════════════════════════════════
# STEP 3 — CODEBASE
# ═══════════════════════════════════════════════════════════════

get_codebase_config() {
    show_step_header 'Codebase project'
    show_progress_bar

    local choice
    choice=$(read_interactive_choice \
        "How do you want to set up the codebase project?" \
        0 \
        "Existing local repo" \
        "Clone from URL" \
        "Create empty (git init)" \
        "Skip (no codebase for now)" \
        -- \
        "Link an existing codebase project already on your machine. The bootstrap adds it to the VS Code workspace as a second root folder (read-only from spec perspective)." \
        "Clone a remote Git repository as the codebase folder. It will be added as a second root in the VS Code workspace." \
        "Creates a new empty folder with git initialized. Perfect for greenfield projects where the codebase does not exist yet." \
        "Do not add a codebase folder now. You can add one later by editing the .code-workspace file manually.")

    case "$choice" in
        0)
            echo ''
            CB_PATH=$(read_value 'Path to codebase repo' '' true)
            if [[ ! -d "$CB_PATH" ]]; then
                w_pad "$(printf "${C_RED}Path not found: %s${C_RESET}" "$CB_PATH")"
                get_codebase_config; return
            fi
            CB_MODE='existing'
            CB_PATH=$(cd "$CB_PATH" && pwd)
            CB_NAME=$(basename "$CB_PATH")
            ;;
        1)
            echo ''
            CB_URL=$(read_value 'Git clone URL' '' true)
            CB_NAME=$(read_value 'Local folder name' "$PROJECT_NAME")
            CB_MODE='clone'
            ;;
        2)
            CB_MODE='empty'
            CB_NAME="$PROJECT_NAME"
            ;;
        3)
            CB_MODE='skip'
            CB_NAME=''
            ;;
    esac

    CURRENT_STEP=4
    show_progress_bar
    sleep 0.3
}

# ═══════════════════════════════════════════════════════════════
# STEP 4 — OPTIONAL SETUP
# ═══════════════════════════════════════════════════════════════

get_extras_config() {
    show_step_header 'Optional setup'
    show_progress_bar

    INSTALL_VENV=false
    INSTALL_EXT=false
    OPEN_VSCODE=false

    if [[ -n "$HAS_PYTHON" ]] && ! $NO_VENV; then
        read_yesno 'Create Python venv & install mkdocs + tools?' && INSTALL_VENV=true
    elif [[ -z "$HAS_PYTHON" ]]; then
        w_pad "$(printf "${C_DIM}○ Python venv — skipped (python not found)${C_RESET}")" 4
    fi

    if [[ -n "$HAS_CODE" ]]; then
        read_yesno 'Install recommended VS Code extensions?' false && INSTALL_EXT=true
        if ! $NO_OPEN; then
            read_yesno 'Open VS Code when done?' true && OPEN_VSCODE=true
        fi
    else
        w_pad "$(printf "${C_DIM}○ VS Code — skipped (code not found)${C_RESET}")" 4
    fi

    CURRENT_STEP=5
    show_progress_bar
    sleep 0.3
}

# ═══════════════════════════════════════════════════════════════
# EXECUTION HELPERS
# ═══════════════════════════════════════════════════════════════

write_task() {
    local label="$1" status="${2:-running}"
    case "$status" in
        running) w_pad "$(printf "${C_CYAN}⟳${C_RESET} %s${C_DIM}...${C_RESET}" "$label")" 4 ;;
        done)    w_pad "$(printf "${C_GREEN}✓${C_RESET} %s" "$label")" 4 ;;
        skip)    w_pad "$(printf "${C_DIM}○ %s — skipped${C_RESET}" "$label")" 4 ;;
        fail)    w_pad "$(printf "${C_RED}✗${C_RESET} %s" "$label")" 4 ;;
    esac
}

write_task_detail() {
    w_pad "$(printf "${C_DIM}└─ %s${C_RESET}" "$1")" 6
}

python_cmd() {
    command -v python3 &>/dev/null && echo python3 || echo python
}

# ═══════════════════════════════════════════════════════════════
# .speckit FILE MANAGEMENT
# ═══════════════════════════════════════════════════════════════

write_speckit_file() {
    local spec_dir="$1" mode="$2"
    local file_path="${spec_dir}/${SPECKIT_FILE}"
    local now
    now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local managed_json=""
    for (( i=0; i<${#MANAGED_PATHS[@]}; i++ )); do
        [[ -n "$managed_json" ]] && managed_json+=","
        managed_json+="
    \"${MANAGED_PATHS[$i]}\""
    done

    local content
    content=$(cat <<EOF
{
  "version": "${SCRIPT_VERSION}",
  "installed": "${now}",
  "updated": null,
  "template": "${TEMPLATE_REPO}",
  "mode": "${mode}",
  "managed": [${managed_json}
  ]
}
EOF
)
    if ! $DRY_RUN; then
        mkdir -p "$(dirname "$file_path")"
        echo "$content" > "$file_path"
    fi
}

get_speckit_version() {
    local spec_dir="$1"
    local file_path="${spec_dir}/${SPECKIT_FILE}"
    if [[ ! -f "$file_path" ]]; then echo ""; return; fi
    grep '"version"' "$file_path" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

update_speckit_file() {
    local spec_dir="$1" new_version="$2"
    local file_path="${spec_dir}/${SPECKIT_FILE}"
    if [[ ! -f "$file_path" ]]; then return; fi
    local now
    now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if ! $DRY_RUN; then
        sed -i.bak "s/\"version\":.*$/\"version\": \"${new_version}\",/" "$file_path"
        sed -i.bak "s/\"updated\":.*$/\"updated\": \"${now}\",/" "$file_path"
        rm -f "${file_path}.bak"
    fi
}

# ═══════════════════════════════════════════════════════════════
# INSTALL EXECUTION
# ═══════════════════════════════════════════════════════════════

invoke_setup() {
    clear_step_area
    echo ''
    w_pad "$(printf "${C_BOLD}${C_WHITE}Setting up workspace...${C_RESET}")"
    w_pad "$(printf "${C_DIM}%s${C_RESET}" "$(printf '─%.0s' {1..56})")"
    echo ''

    local spec_dir="$BASE_DIR/$SPEC_NAME"
    local workspace_file="$BASE_DIR/${PROJECT_NAME}.code-workspace"

    # ── Spec repo ──────────────────────────────────────
    case "$SPEC_MODE" in
        template)
            write_task 'Creating spec repo from GitHub template'
            local full_name="${SPEC_ORG}/${SPEC_NAME}"
            if ! $DRY_RUN; then
                pushd "$BASE_DIR" >/dev/null
                gh repo create "$full_name" \
                    --template "$TEMPLATE_REPO" \
                    --"$SPEC_VIS" \
                    --clone 2>&1 >/dev/null
                popd >/dev/null
            fi
            write_task 'Creating spec repo from GitHub template' 'done'
            write_task_detail "$full_name ($SPEC_VIS)"
            ;;
        clone)
            write_task 'Cloning spec template'
            if ! $DRY_RUN; then
                pushd "$BASE_DIR" >/dev/null
                git clone "$TEMPLATE_URL" "$SPEC_NAME" 2>&1 >/dev/null
                rm -rf "$spec_dir/.git"
                pushd "$spec_dir" >/dev/null
                git init -q
                git add -A
                git commit -m 'chore: init from spec-kit-template' -q
                popd >/dev/null
                popd >/dev/null
            fi
            write_task 'Cloning spec template' 'done'
            write_task_detail "$spec_dir"
            ;;
        existing)
            spec_dir="$SPEC_PATH"
            SPEC_NAME=$(basename "$spec_dir")
            write_task 'Using existing spec repo' 'done'
            write_task_detail "$spec_dir"
            ;;
    esac

    # ── Codebase ───────────────────────────────────────
    local codebase_dir=""
    case "$CB_MODE" in
        existing)
            codebase_dir="$CB_PATH"
            write_task 'Linking existing codebase' 'done'
            write_task_detail "$codebase_dir"
            ;;
        clone)
            codebase_dir="$BASE_DIR/$CB_NAME"
            write_task 'Cloning codebase'
            if ! $DRY_RUN; then
                pushd "$BASE_DIR" >/dev/null
                git clone "$CB_URL" "$CB_NAME" 2>&1 >/dev/null
                popd >/dev/null
            fi
            write_task 'Cloning codebase' 'done'
            write_task_detail "$codebase_dir"
            ;;
        empty)
            codebase_dir="$BASE_DIR/$CB_NAME"
            write_task 'Creating empty codebase'
            if ! $DRY_RUN; then
                mkdir -p "$codebase_dir"
                pushd "$codebase_dir" >/dev/null
                git init -q
                popd >/dev/null
            fi
            write_task 'Creating empty codebase' 'done'
            write_task_detail "$codebase_dir"
            ;;
        skip)
            write_task 'Codebase' 'skip'
            ;;
    esac

    # ── Workspace file ─────────────────────────────────
    write_task 'Generating workspace file'

    local spec_rel
    spec_rel=$(python3 -c "import os.path; print(os.path.relpath('$spec_dir','$(dirname "$workspace_file")'))" 2>/dev/null \
        || echo "./$SPEC_NAME")

    local cb_rel=""
    [[ -n "$codebase_dir" ]] && cb_rel=$(python3 -c "import os.path; print(os.path.relpath('$codebase_dir','$(dirname "$workspace_file")'))" 2>/dev/null \
        || echo "./$CB_NAME")

    local ws_json
    if [[ -n "$codebase_dir" ]]; then
        ws_json=$(cat <<WSJSON
{
  "folders": [
    { "name": "spec",     "path": "$spec_rel" },
    { "name": "codebase", "path": "$cb_rel" }
  ],
  "settings": {
    "powershell.cwd": "codebase",
    "chat.useAgentSkills": true
  },
  "extensions": {
    "recommendations": [
      "GitHub.copilot",
      "GitHub.copilot-chat"
    ]
  }
}
WSJSON
)
    else
        ws_json=$(cat <<WSJSON
{
  "folders": [
    { "name": "spec", "path": "$spec_rel" }
  ],
  "settings": {
    "chat.useAgentSkills": true
  },
  "extensions": {
    "recommendations": [
      "GitHub.copilot",
      "GitHub.copilot-chat"
    ]
  }
}
WSJSON
)
    fi

    if ! $DRY_RUN; then
        echo "$ws_json" > "$workspace_file"
    fi
    write_task 'Generating workspace file' 'done'
    write_task_detail "$(basename "$workspace_file")"

    # ── .speckit control file ──────────────────────────
    write_task 'Generating version control file'
    write_speckit_file "$spec_dir" "$SPEC_MODE"
    write_task 'Generating version control file' 'done'
    write_task_detail "$SPECKIT_FILE"

    # ── Python venv ────────────────────────────────────
    if $INSTALL_VENV; then
        write_task 'Creating Python venv + dependencies'
        if ! $DRY_RUN; then
            local py
            py=$(python_cmd)
            pushd "$spec_dir" >/dev/null
            $py -m venv .venv
            local pip_exe=".venv/bin/pip"
            [[ -f ".venv/Scripts/pip.exe" ]] && pip_exe=".venv/Scripts/pip.exe"
            $pip_exe install --quiet mkdocs mkdocs-material pyyaml 2>&1 >/dev/null
            [[ -f "tools/requirements.txt" ]] && $pip_exe install --quiet -r tools/requirements.txt 2>&1 >/dev/null
            popd >/dev/null
        fi
        write_task 'Creating Python venv + dependencies' 'done'
        write_task_detail 'mkdocs, mkdocs-material, pyyaml'
    else
        write_task 'Python venv' 'skip'
    fi

    # ── VS Code extensions ─────────────────────────────
    if $INSTALL_EXT; then
        write_task 'Installing VS Code extensions'
        if ! $DRY_RUN; then
            code --install-extension GitHub.copilot      --force 2>&1 >/dev/null
            code --install-extension GitHub.copilot-chat --force 2>&1 >/dev/null
        fi
        write_task 'Installing VS Code extensions' 'done'
        write_task_detail 'GitHub.copilot, GitHub.copilot-chat'
    else
        write_task 'VS Code extensions' 'skip'
    fi

    # ── Summary ────────────────────────────────────────
    show_install_summary "$workspace_file" "$spec_dir" "$codebase_dir"

    # ── Open VS Code ───────────────────────────────────
    if $OPEN_VSCODE && ! $DRY_RUN; then
        code "$workspace_file" 2>/dev/null &
    fi
}

# ═══════════════════════════════════════════════════════════════
# INSTALL SUMMARY
# ═══════════════════════════════════════════════════════════════

show_install_summary() {
    local workspace_file="$1" spec_dir="$2" codebase_dir="$3"

    if $USE_TUI; then
        cursor_at $(( PROGRESS_TOP + PROGRESS_HEIGHT + 1 )) 0
    fi

    local ws_base ws_name spec_leaf
    ws_base=$(dirname "$workspace_file")
    ws_name=$(basename "$workspace_file")
    spec_leaf=$(basename "$spec_dir")

    echo ''
    printf "  ${C_GREEN}${C_BOLD}╔══════════════════════════════════════════════════════════════╗${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}${C_GREEN}✓ DONE!${C_RESET}                                                    ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_DIM}%s/${C_RESET}\n" "$ws_base"
    printf "  ${C_GREEN}║${C_RESET}    ├── ${C_CYAN}%s/${C_RESET}              ${C_DIM}spec${C_RESET}\n" "$spec_leaf"

    if [[ -n "$codebase_dir" ]]; then
        local cb_leaf
        cb_leaf=$(basename "$codebase_dir")
        printf "  ${C_GREEN}║${C_RESET}    ├── ${C_BLUE}%s/${C_RESET}                  ${C_DIM}codebase${C_RESET}\n" "$cb_leaf"
    fi

    printf "  ${C_GREEN}║${C_RESET}    └── ${C_WHITE}%s${C_RESET}     ${C_DIM}workspace${C_RESET}\n" "$ws_name"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}Next steps:${C_RESET}                                                ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}    1. Open the workspace in VS Code                          ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}    2. In Copilot Chat: ${C_CYAN}@spc-spec-director${C_RESET}                    ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}    3. Or run ${C_CYAN}/new-spec${C_RESET} to start the specification           ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}SPEC KIT${C_RESET} by ${C_CYAN}LKS Next${C_RESET}                                       ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_DIM}Thank you for using SPEC KIT!${C_RESET}                               ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}${C_BOLD}╚══════════════════════════════════════════════════════════════╝${C_RESET}\n"
    echo ''
}

# ═══════════════════════════════════════════════════════════════
# UPDATE: REMOTE VERSION CHECK
# ═══════════════════════════════════════════════════════════════

get_remote_version() {
    local remote_version=""

    # Strategy 1: gh api (fast, no clone)
    if [[ -n "$HAS_GH" ]]; then
        remote_version=$(gh api "repos/${TEMPLATE_REPO}/contents/VERSION" --jq '.content' 2>/dev/null \
            | base64 -d 2>/dev/null \
            | tr -d '[:space:]') || true
    fi

    # Strategy 2: shallow clone (universal fallback)
    if [[ -z "$remote_version" ]]; then
        UPDATE_TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/speckit-update-XXXXXXXX")
        git clone --depth 1 --filter=blob:none --sparse "$TEMPLATE_URL" "$UPDATE_TMP_DIR" 2>/dev/null || true
        if [[ -d "$UPDATE_TMP_DIR" ]]; then
            pushd "$UPDATE_TMP_DIR" >/dev/null 2>&1
            git sparse-checkout set VERSION CHANGELOG.md 2>/dev/null || true
            popd >/dev/null 2>&1
            local version_file="$UPDATE_TMP_DIR/VERSION"
            if [[ -f "$version_file" ]]; then
                remote_version=$(cat "$version_file" | tr -d '[:space:]')
            fi
        fi
    fi

    echo "$remote_version"
}

get_remote_changelog() {
    local from_version="$1" to_version="$2"
    local changelog=""

    if [[ -n "$UPDATE_TMP_DIR" ]] && [[ -f "$UPDATE_TMP_DIR/CHANGELOG.md" ]]; then
        changelog=$(cat "$UPDATE_TMP_DIR/CHANGELOG.md")
    fi

    if [[ -z "$changelog" ]] && [[ -n "$HAS_GH" ]]; then
        changelog=$(gh api "repos/${TEMPLATE_REPO}/contents/CHANGELOG.md" --jq '.content' 2>/dev/null \
            | base64 -d 2>/dev/null) || true
    fi

    if [[ -z "$changelog" ]]; then return; fi

    local capture=false
    local result=""
    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]]+\[ ]]; then
            if $capture; then break; fi
            if [[ "$line" != *"$from_version"* ]]; then
                capture=true
            fi
        fi
        if $capture; then
            result+="$line"$'\n'
        fi
    done <<< "$changelog"

    echo "$result"
}

# ═══════════════════════════════════════════════════════════════
# UPDATE: FULL CLONE FOR FILE COPY
# ═══════════════════════════════════════════════════════════════

get_update_source() {
    if [[ -n "$UPDATE_TMP_DIR" ]] && [[ -d "$UPDATE_TMP_DIR" ]]; then
        pushd "$UPDATE_TMP_DIR" >/dev/null 2>&1
        git sparse-checkout set "${MANAGED_PATHS[@]}" 2>/dev/null || true
        popd >/dev/null 2>&1
        echo "$UPDATE_TMP_DIR"
        return
    fi

    UPDATE_TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/speckit-update-XXXXXXXX")
    git clone --depth 1 "$TEMPLATE_URL" "$UPDATE_TMP_DIR" 2>/dev/null || true
    echo "$UPDATE_TMP_DIR"
}

# ═══════════════════════════════════════════════════════════════
# UPDATE: GIT STATUS CHECK
# ═══════════════════════════════════════════════════════════════

test_git_clean() {
    local spec_dir="$1"
    local dirty_files=""

    pushd "$spec_dir" >/dev/null 2>&1
    for managed_path in "${MANAGED_PATHS[@]}"; do
        if [[ -e "$managed_path" ]]; then
            local status
            status=$(git status --porcelain -- "$managed_path" 2>/dev/null || true)
            if [[ -n "$status" ]]; then
                dirty_files+="$status"$'\n'
            fi
        fi
    done
    popd >/dev/null 2>&1

    echo "$dirty_files"
}

# ═══════════════════════════════════════════════════════════════
# UPDATE: APPLY
# ═══════════════════════════════════════════════════════════════

invoke_update() {
    local spec_dir="$1" source_dir="$2"

    echo ''
    w_pad "$(printf "${C_BOLD}${C_WHITE}Updating SPEC-KIT...${C_RESET}")"
    w_pad "$(printf "${C_DIM}%s${C_RESET}" "$(printf '─%.0s' {1..56})")"
    echo ''

    UPDATED_COUNT=0
    ADDED_COUNT=0
    UPDATED_FOLDERS=()

    for managed_path in "${MANAGED_PATHS[@]}"; do
        local src="${source_dir}/${managed_path}"
        local dst="${spec_dir}/${managed_path}"

        [[ ! -e "$src" ]] && continue

        local label="$managed_path"

        if [[ -d "$src" ]]; then
            write_task "Updating ${label}"
            if ! $DRY_RUN; then
                [[ -e "$dst" ]] && rm -rf "$dst"
                cp -r "$src" "$dst"
            fi
            local count
            count=$(find "$src" -type f | wc -l | tr -d ' ')
            UPDATED_COUNT=$(( UPDATED_COUNT + count ))
            UPDATED_FOLDERS+=("$label")
            write_task "Updating ${label}" 'done'
            write_task_detail "${count} files"
        else
            local existed=false
            [[ -e "$dst" ]] && existed=true
            write_task "Updating ${label}"
            if ! $DRY_RUN; then
                mkdir -p "$(dirname "$dst")"
                cp "$src" "$dst"
            fi
            if $existed; then
                UPDATED_COUNT=$(( UPDATED_COUNT + 1 ))
            else
                ADDED_COUNT=$(( ADDED_COUNT + 1 ))
            fi
            write_task "Updating ${label}" 'done'
        fi
    done
}

# ═══════════════════════════════════════════════════════════════
# UPDATE: CLEANUP
# ═══════════════════════════════════════════════════════════════

remove_update_temp() {
    if [[ -n "$UPDATE_TMP_DIR" ]] && [[ -d "$UPDATE_TMP_DIR" ]]; then
        rm -rf "$UPDATE_TMP_DIR"
        UPDATE_TMP_DIR=""
    fi
}

# ═══════════════════════════════════════════════════════════════
# UPDATE SUMMARY
# ═══════════════════════════════════════════════════════════════

show_update_summary() {
    local from_version="$1" to_version="$2"

    echo ''
    printf "  ${C_GREEN}${C_BOLD}╔══════════════════════════════════════════════════════════════╗${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}${C_GREEN}Updated: v%s -> v%s${C_RESET}\n" "$from_version" "$to_version"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}Updated areas:${C_RESET}\n"

    for folder in "${UPDATED_FOLDERS[@]}"; do
        printf "  ${C_GREEN}║${C_RESET}    ${C_CYAN}*${C_RESET} %s\n" "$folder"
    done

    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_DIM}Total: %d files updated, %d files added${C_RESET}\n" "$UPDATED_COUNT" "$ADDED_COUNT"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_YELLOW}!!${C_RESET}  ${C_BOLD}Reload VS Code to apply changes${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}     Ctrl+Shift+P -> ${C_CYAN}Reload Window${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}SPEC KIT${C_RESET} by ${C_CYAN}LKS Next${C_RESET}                                       ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_DIM}Thank you for using SPEC KIT!${C_RESET}                               ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}${C_BOLD}╚══════════════════════════════════════════════════════════════╝${C_RESET}\n"
    echo ''
}

# ═══════════════════════════════════════════════════════════════
# UPDATE FLOW
# ═══════════════════════════════════════════════════════════════

invoke_update_flow() {
    local spec_dir="$1"
    local local_version
    local_version=$(get_speckit_version "$spec_dir")

    echo ''
    w_pad "$(printf "${C_BOLD}Existing SPEC-KIT project detected${C_RESET}")"
    w_pad "$(printf "${C_DIM}Installed: v%s${C_RESET}" "$local_version")"
    echo ''
    w_pad "$(printf "${C_DIM}Checking for updates...${C_RESET}")"

    # Minimal prerequisite check
    HAS_GIT=$(get_tool_version git --version)
    if [[ -z "$HAS_GIT" ]]; then
        w_pad "$(printf "${C_RED}Git is required. Aborting.${C_RESET}")"
        exit 1
    fi
    HAS_GH=$(get_tool_version gh --version)
    HAS_CODE=$(get_tool_version code --version)

    local remote_version
    remote_version=$(get_remote_version)

    if [[ -z "$remote_version" ]]; then
        echo ''
        w_pad "$(printf "${C_RED}Could not check remote version. Verify internet connection and try again.${C_RESET}")"
        exit 1
    fi

    # --check flag: just report and exit
    if $CHECK; then
        if [[ "$remote_version" == "$local_version" ]]; then
            w_pad "$(printf "${C_GREEN}✓ SPEC-KIT is up to date (v%s)${C_RESET}" "$local_version")"
            remove_update_temp
            exit 0
        else
            w_pad "$(printf "${C_YELLOW}Update available: v%s -> v%s${C_RESET}" "$local_version" "$remote_version")"
            remove_update_temp
            exit 1
        fi
    fi

    if [[ "$remote_version" == "$local_version" ]]; then
        echo ''
        w_pad "$(printf "${C_GREEN}✓ SPEC-KIT is up to date (v%s)${C_RESET}" "$local_version")"
        echo ''
        w_pad "$(printf "${C_BOLD}SPEC KIT${C_RESET} by ${C_CYAN}LKS Next${C_RESET}")"
        w_pad "$(printf "${C_DIM}Thank you for using SPEC KIT!${C_RESET}")"
        echo ''
        if ! $UPDATE; then
            remove_update_temp
            return
        fi
        w_pad "$(printf "${C_YELLOW}--update flag set. Forcing re-application of v%s.${C_RESET}" "$local_version")"
    else
        echo ''
        w_pad "$(printf "${C_CYAN}New version available: v%s -> v%s${C_RESET}" "$local_version" "$remote_version")"
    fi

    echo ''

    local update_done=false
    while ! $update_done; do
        local target_label
        if [[ "$remote_version" == "$local_version" ]]; then
            target_label="Re-apply v${remote_version}"
        else
            target_label="Update to v${remote_version}"
        fi

        local menu_choice
        menu_choice=$(read_interactive_choice \
            "What would you like to do?" \
            0 \
            "$target_label" \
            "View changelog" \
            "View files that will change" \
            "Skip update" \
            -- \
            "Updates all managed files: agents, skills, prompts, instructions, docs/kit, tools, and config files. Your spec documents (docs/spec/**) and codebase will NOT be modified." \
            "Shows the changelog entries between your installed version (v${local_version}) and the available version (v${remote_version})." \
            "Shows which files in your project will be overwritten by the update. Only managed SPEC-KIT files are affected." \
            "Exit without making any changes. You can run the bootstrap again later to update.")

        case "$menu_choice" in
            0)
                # UPDATE
                local dirty_files
                dirty_files=$(test_git_clean "$spec_dir")
                if [[ -n "$dirty_files" ]]; then
                    echo ''
                    w_pad "$(printf "${C_YELLOW}!!  You have uncommitted changes in managed files:${C_RESET}")"
                    echo "$dirty_files" | head -10 | while IFS= read -r f; do
                        [[ -n "$f" ]] && w_pad "$(printf "${C_DIM}    %s${C_RESET}" "$f")" 4
                    done
                    local dirty_count
                    dirty_count=$(echo "$dirty_files" | grep -c . || true)
                    if (( dirty_count > 10 )); then
                        w_pad "$(printf "${C_DIM}    ... and %d more${C_RESET}" "$(( dirty_count - 10 ))")" 4
                    fi
                    echo ''
                    w_pad "The update will overwrite these files. Make sure your"
                    w_pad "Git repository is up to date so you can recover if needed."
                    echo ''

                    local confirm_choice
                    confirm_choice=$(read_interactive_choice \
                        "How do you want to proceed?" \
                        1 \
                        "Continue anyway (I can recover with git)" \
                        "Abort (I will commit first)" \
                        -- \
                        "The update will proceed and overwrite the changed files. You can always use git checkout or git stash to recover them later." \
                        "Stops the update so you can commit or stash your changes first. Run the bootstrap again when ready.")

                    if [[ "$confirm_choice" == "1" ]]; then
                        echo ''
                        w_pad "$(printf "${C_DIM}Update cancelled. Commit your changes and try again.${C_RESET}")"
                        remove_update_temp
                        return
                    fi
                else
                    echo ''
                    w_pad "$(printf "${C_GREEN}✓ Working tree is clean — safe to update.${C_RESET}")"
                fi

                echo ''
                w_pad "$(printf "${C_DIM}Downloading update files...${C_RESET}")"
                local source_dir
                source_dir=$(get_update_source)

                if [[ -z "$source_dir" ]] || [[ ! -d "$source_dir" ]]; then
                    w_pad "$(printf "${C_RED}Failed to download update source. Try again.${C_RESET}")"
                    remove_update_temp
                    return
                fi

                invoke_update "$spec_dir" "$source_dir"
                update_speckit_file "$spec_dir" "$remote_version"
                remove_update_temp
                show_update_summary "$local_version" "$remote_version"

                # Offer VS Code reload
                if [[ -n "$HAS_CODE" ]]; then
                    local reload_choice
                    reload_choice=$(read_interactive_choice \
                        "VS Code needs to reload to apply agent/skill changes." \
                        0 \
                        "Reload VS Code now (reopens workspace)" \
                        "I will reload manually (Ctrl+Shift+P -> Reload Window)" \
                        -- \
                        "Opens the workspace file which will trigger VS Code to reload and pick up the updated agents, skills, and instructions." \
                        "You will need to manually reload VS Code by pressing Ctrl+Shift+P and typing Reload Window to apply the changes.")

                    if [[ "$reload_choice" == "0" ]] && ! $DRY_RUN; then
                        local ws_files
                        ws_files=$(find "$(dirname "$spec_dir")" -maxdepth 1 -name "*.code-workspace" -type f 2>/dev/null | head -1)
                        if [[ -n "$ws_files" ]]; then
                            code "$ws_files" --reuse-window 2>/dev/null &
                        fi
                    fi
                fi

                update_done=true
                ;;
            1)
                # VIEW CHANGELOG
                echo ''
                local cl_content
                cl_content=$(get_remote_changelog "$local_version" "$remote_version")
                if [[ -n "$cl_content" ]]; then
                    printf "  ${C_CYAN}+--- Changelog: v%s -> v%s ---+${C_RESET}\n" "$local_version" "$remote_version"
                    while IFS= read -r line; do
                        printf "  ${C_DIM}|${C_RESET}  %s\n" "$line"
                    done <<< "$cl_content"
                    printf "  ${C_CYAN}+%s+${C_RESET}\n" "$(printf '%.0s-' {1..50})"
                else
                    w_pad "$(printf "${C_DIM}No changelog available. Check the GitHub releases page for details.${C_RESET}")"
                fi
                read_continue
                echo ''
                ;;
            2)
                # VIEW FILES THAT WILL CHANGE
                echo ''
                printf "  ${C_CYAN}+--- Files managed by SPEC-KIT ---+${C_RESET}\n"
                for mp in "${MANAGED_PATHS[@]}"; do
                    local full_path="${spec_dir}/${mp}"
                    if [[ -d "$full_path" ]]; then
                        local file_count
                        file_count=$(find "$full_path" -type f 2>/dev/null | wc -l | tr -d ' ')
                        printf "  ${C_DIM}|${C_RESET}  ${C_CYAN}%s/${C_RESET}  ${C_DIM}(%s files)${C_RESET}\n" "$mp" "$file_count"
                    elif [[ -f "$full_path" ]]; then
                        printf "  ${C_DIM}|${C_RESET}  %s\n" "$mp"
                    else
                        printf "  ${C_DIM}|${C_RESET}  ${C_GREEN}+ %s${C_RESET}  ${C_DIM}(new)${C_RESET}\n" "$mp"
                    fi
                done
                printf "  ${C_CYAN}+%s+${C_RESET}\n" "$(printf '%.0s-' {1..35})"
                echo ''
                w_pad "$(printf "${C_DIM}These paths will be overwritten. docs/spec/** is NOT affected.${C_RESET}")"
                read_continue
                echo ''
                ;;
            3)
                # SKIP
                echo ''
                w_pad "$(printf "${C_DIM}Update skipped. Run bootstrap again when ready.${C_RESET}")"
                echo ''
                remove_update_temp
                update_done=true
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# MODE DETECTION
# ═══════════════════════════════════════════════════════════════

detect_mode() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local spec_dir
    spec_dir="$(dirname "$script_dir")"
    local speckit_path="${spec_dir}/${SPECKIT_FILE}"

    if [[ -f "$speckit_path" ]]; then
        RUN_MODE="update"
        echo "$spec_dir"
    else
        RUN_MODE="install"
        echo ""
    fi
}

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

main() {
    USE_TUI=$(test_tui_support)
    UPDATE_TMP_DIR=""

    if $DRY_RUN; then
        printf "${C_YELLOW}[DRY RUN] No files will be created or modified.${C_RESET}\n\n"
    fi

    show_header

    local spec_dir
    spec_dir=$(detect_mode)

    if [[ "$RUN_MODE" == "update" ]]; then
        invoke_update_flow "$spec_dir"
    else
        test_prerequisites
        get_project_config
        get_spec_config
        get_codebase_config
        get_extras_config
        invoke_setup
    fi
}

main
