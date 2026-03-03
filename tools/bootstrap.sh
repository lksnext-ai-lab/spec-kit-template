#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  Spec Kit — Workspace Bootstrap (Unix)
#
#  Sets up a complete spec-kit workspace: creates the spec project
#  from the GitHub template, links (or creates) a codebase project,
#  generates the VS Code .code-workspace file, and optionally
#  installs Python/mkdocs dependencies.
#
#  Requirements: bash 4+, git.
#  Optional: gh (GitHub CLI), python3, code (VS Code CLI).
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

TEMPLATE_REPO="lksnext-ai-lab/spec-kit-template"
TEMPLATE_URL="https://github.com/$TEMPLATE_REPO.git"
SCRIPT_VERSION="1.0.0"

# ── Flags ──────────────────────────────────────────────────
WORKSPACE_ONLY=false
NO_VENV=false
NO_OPEN=false
YES=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace-only) WORKSPACE_ONLY=true ;;
        --no-venv)        NO_VENV=true ;;
        --no-open)        NO_OPEN=true ;;
        --yes)            YES=true ;;
        --dry-run)        DRY_RUN=true ;;
        -h|--help)
            echo "Usage: bootstrap.sh [--workspace-only] [--no-venv] [--no-open] [--yes] [--dry-run]"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# ── TUI geometry ──────────────────────────────────────────
HEADER_HEIGHT=13
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
C_CYAN='\033[36m'
C_RED='\033[31m'
C_BLUE='\033[34m'
C_WHITE='\033[97m'

# ── State ─────────────────────────────────────────────────
USE_TUI=false
CURRENT_STEP=0
TOTAL_STEPS=5

HAS_GIT="" ; HAS_CODE="" ; HAS_GH="" ; HAS_PYTHON=""

PROJECT_NAME="" ; SPEC_NAME="" ; BASE_DIR=""
SPEC_MODE="" ; SPEC_ORG="" ; SPEC_VIS="" ; SPEC_PATH=""
CB_MODE="" ; CB_NAME="" ; CB_PATH="" ; CB_URL=""
INSTALL_VENV=false ; INSTALL_EXT=false ; OPEN_VSCODE=false

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

show_header() {
    $USE_TUI && clear

    echo ''
    printf "  ${C_CYAN}${C_BOLD}╔══════════════════════════════════════════════════════════════╗${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}      ${C_BOLD}${C_WHITE}_____ ____  ___________${C_RESET}     ${C_BOLD}${C_CYAN}__ __ ________${C_RESET}                ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}     ${C_BOLD}${C_WHITE}/ ___// __ \\/ ____/ ___/${C_RESET}    ${C_BOLD}${C_CYAN}/ //_//  _/_  __/${C_RESET}            ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}     ${C_BOLD}${C_WHITE}\\__ \\/ /_/ / __/ / /${C_RESET}       ${C_BOLD}${C_CYAN}/ ,<   / /  / /${C_RESET}               ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}    ${C_BOLD}${C_WHITE}___/ / ____/ /___/ /___${C_RESET}    ${C_BOLD}${C_CYAN}/ /| |_/ /  / /${C_RESET}                ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}   ${C_BOLD}${C_WHITE}/____/_/   /_____/\\____/${C_RESET}   ${C_BOLD}${C_CYAN}/_/ |_/___/ /_/${C_RESET}                 ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}  ${C_DIM}Workspace Bootstrap${C_RESET}                              ${C_DIM}v${SCRIPT_VERSION}${C_RESET}  ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}║${C_RESET}                                                              ${C_CYAN}║${C_RESET}\n"
    printf "  ${C_CYAN}${C_BOLD}╚══════════════════════════════════════════════════════════════╝${C_RESET}\n"
}

# ═══════════════════════════════════════════════════════════════
# PROGRESS BAR
# ═══════════════════════════════════════════════════════════════

show_progress_bar() {
    $USE_TUI || return
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
    [[ -n "$default" ]] && display_default=" ${C_DIM}[${default}]${C_RESET}"
    printf "  ${C_CYAN}▸${C_RESET} %b%b: " "$prompt" "$display_default"
    local val
    read -r val
    val="${val## }" ; val="${val%% }"
    if [[ -z "$val" ]]; then
        if [[ -n "$default" ]]; then echo "$default"; return; fi
        if $required; then
            w_pad "Value required." 2 "$C_RED"
            read_value "$prompt" "$default" "$required"
            return
        fi
        echo ''
    else
        echo "$val"
    fi
}

read_choice() {
    local prompt="$1" default="$2"
    shift 2
    local options=("$@")
    for (( i=0; i<${#options[@]}; i++ )); do
        local num=$(( i + 1 ))
        local marker=""
        (( num == default )) && marker=" $(printf "${C_GREEN}← default${C_RESET}")"
        w_pad "$(printf "${C_BOLD}[%d]${C_RESET} %s%b" "$num" "${options[$i]}" "$marker")" 4
    done
    echo ''
    printf "  ${C_CYAN}▸${C_RESET} %s ${C_DIM}[%d]${C_RESET}: " "$prompt" "$default"
    local val
    read -r val
    if [[ -z "$val" ]]; then echo "$default"; return; fi
    if [[ "$val" =~ ^[0-9]+$ ]] && (( val >= 1 && val <= ${#options[@]} )); then
        echo "$val"
    else
        w_pad "Invalid choice." 2 "$C_RED"
        read_choice "$prompt" "$default" "${options[@]}"
    fi
}

read_yesno() {
    local prompt="$1" default="${2:-true}"
    local hint
    $default && hint="Y/n" || hint="y/N"
    printf "  ${C_CYAN}▸${C_RESET} %s ${C_DIM}[%s]${C_RESET}: " "$prompt" "$hint"
    local val
    read -r val
    if [[ -z "$val" ]]; then $default && return 0 || return 1; fi
    [[ "$val" =~ ^[yYsS] ]] && return 0 || return 1
}

read_continue() {
    echo ''
    printf "  ${C_DIM}Press Enter to continue...${C_RESET}"
    read -r _
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
    # Sanitize
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

    local opts=()
    local default_choice
    if [[ -n "$HAS_GH" ]]; then
        opts+=("Create from GitHub template (requires gh CLI)")
        default_choice=1
    else
        opts+=("Create from GitHub template (gh not found — install first)")
        default_choice=2
    fi
    opts+=("Clone template locally (no GitHub repo)")
    opts+=("I already have the spec cloned")

    local choice
    choice=$(read_choice 'Choose' "$default_choice" "${opts[@]}")

    case "$choice" in
        1)
            if [[ -z "$HAS_GH" ]]; then
                w_pad "$(printf "${C_YELLOW}gh CLI not found. Falling back to clone.${C_RESET}")"
                SPEC_MODE='clone'
            else
                echo ''
                SPEC_ORG=$(read_value 'GitHub org/user for the new repo' 'lksnext-ai-lab')
                local vis
                vis=$(read_choice 'Visibility' 1 "Private" "Public")
                SPEC_MODE='template'
                [[ "$vis" == "1" ]] && SPEC_VIS='private' || SPEC_VIS='public'
            fi
            ;;
        2) SPEC_MODE='clone' ;;
        3)
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
    choice=$(read_choice 'Choose' 1 \
        "Existing local repo" \
        "Clone from URL" \
        "Create empty (git init)" \
        "Skip (no codebase for now)")

    case "$choice" in
        1)
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
        2)
            echo ''
            CB_URL=$(read_value 'Git clone URL' '' true)
            CB_NAME=$(read_value 'Local folder name' "$PROJECT_NAME")
            CB_MODE='clone'
            ;;
        3)
            CB_MODE='empty'
            CB_NAME="$PROJECT_NAME"
            ;;
        4)
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
        read_yesno 'Install recommended VS Code extensions?' && INSTALL_EXT=true
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
# EXECUTION
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
    show_summary "$workspace_file" "$spec_dir" "$codebase_dir"

    # ── Open VS Code ───────────────────────────────────
    if $OPEN_VSCODE && ! $DRY_RUN; then
        code "$workspace_file" 2>/dev/null &
    fi
}

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════

show_summary() {
    local workspace_file="$1" spec_dir="$2" codebase_dir="$3"

    if $USE_TUI; then
        cursor_at $(( PROGRESS_TOP + PROGRESS_HEIGHT + 1 )) 0
    fi

    local ws_base ws_name spec_leaf cb_leaf
    ws_base=$(dirname "$workspace_file")
    ws_name=$(basename "$workspace_file")
    spec_leaf=$(basename "$spec_dir")

    echo ''
    printf "  ${C_GREEN}${C_BOLD}╔══════════════════════════════════════════════════════════════╗${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}${C_GREEN}✓ DONE!${C_RESET}                                                    ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_DIM}%s/${C_RESET}                                      ${C_GREEN}║${C_RESET}\n" "$ws_base"
    printf "  ${C_GREEN}║${C_RESET}    ├── ${C_CYAN}%s/${C_RESET}              ${C_DIM}spec${C_RESET}         ${C_GREEN}║${C_RESET}\n" "$spec_leaf"

    if [[ -n "$codebase_dir" ]]; then
        cb_leaf=$(basename "$codebase_dir")
        printf "  ${C_GREEN}║${C_RESET}    ├── ${C_BLUE}%s/${C_RESET}                  ${C_DIM}codebase${C_RESET}     ${C_GREEN}║${C_RESET}\n" "$cb_leaf"
    fi

    printf "  ${C_GREEN}║${C_RESET}    └── ${C_WHITE}%s${C_RESET}     ${C_DIM}workspace${C_RESET}   ${C_GREEN}║${C_RESET}\n" "$ws_name"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}╠══════════════════════════════════════════════════════════════╣${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}  ${C_BOLD}Next steps:${C_RESET}                                                ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}    1. Open the workspace in VS Code                          ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}    2. In Copilot Chat: ${C_CYAN}@spc-spec-director${C_RESET}                    ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}    3. Or run ${C_CYAN}/new-spec${C_RESET} to start the specification           ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}║${C_RESET}                                                              ${C_GREEN}║${C_RESET}\n"
    printf "  ${C_GREEN}${C_BOLD}╚══════════════════════════════════════════════════════════════╝${C_RESET}\n"
    echo ''
}

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

main() {
    USE_TUI=$(test_tui_support)

    if $DRY_RUN; then
        printf "${C_YELLOW}[DRY RUN] No files will be created or modified.${C_RESET}\n\n"
    fi

    show_header
    test_prerequisites
    get_project_config
    get_spec_config
    get_codebase_config
    get_extras_config
    invoke_setup
}

main
