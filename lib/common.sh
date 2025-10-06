#!/usr/bin/env bash
# common.sh - Shared helper functions for shell scripts library
# Source this file in your scripts: source "$(dirname "$0")/../lib/common.sh"

set -Eeuo pipefail
IFS=$'\n\t'

# Colors for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    NC=''
fi

# ============================================================================
# OS Detection
# ============================================================================

is_mac() {
    [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_wsl() {
    [[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

is_wayland() {
    [[ -n "${WAYLAND_DISPLAY:-}" ]]
}

is_x11() {
    [[ -n "${DISPLAY:-}" ]] && ! is_wayland
}

get_os() {
    if is_mac; then
        echo "macos"
    elif is_wsl; then
        echo "wsl"
    elif is_linux; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# ============================================================================
# Logging Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $*" >&2
    fi
}

# ============================================================================
# Command Checking
# ============================================================================

have_cmd() {
    command -v "$1" &>/dev/null
}

need_cmd() {
    if ! have_cmd "$1"; then
        die "Required command '$1' not found. Please install it first."
    fi
}

# ============================================================================
# Error Handling
# ============================================================================

die() {
    log_error "$@"
    exit 1
}

trap_err() {
    local line=$1
    log_error "Error on line $line"
}

setup_error_trap() {
    trap 'trap_err $LINENO' ERR
}

# ============================================================================
# User Interaction
# ============================================================================

confirm() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-n}"
    
    local yn_prompt
    if [[ "$default" == "y" ]]; then
        yn_prompt="[Y/n]"
    else
        yn_prompt="[y/N]"
    fi
    
    read -r -p "$prompt $yn_prompt " response
    
    response=${response:-$default}
    
    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================================
# Retry Logic
# ============================================================================

retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-2}"
    shift 2
    local cmd=("$@")
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if "${cmd[@]}"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            log_warn "Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
        fi
        
        attempt=$((attempt + 1))
    done
    
    log_error "Command failed after $max_attempts attempts"
    return 1
}

# ============================================================================
# Clipboard Functions (cross-platform)
# ============================================================================

get_clipboard_cmd() {
    local mode="${1:-copy}"  # copy or paste
    
    if is_mac; then
        if [[ "$mode" == "copy" ]]; then
            echo "pbcopy"
        else
            echo "pbpaste"
        fi
    elif is_linux; then
        if is_wayland; then
            if [[ "$mode" == "copy" ]]; then
                if have_cmd wl-copy; then
                    echo "wl-copy"
                else
                    return 1
                fi
            else
                if have_cmd wl-paste; then
                    echo "wl-paste"
                else
                    return 1
                fi
            fi
        elif is_x11; then
            if have_cmd xclip; then
                if [[ "$mode" == "copy" ]]; then
                    echo "xclip -selection clipboard"
                else
                    echo "xclip -selection clipboard -o"
                fi
            elif have_cmd xsel; then
                if [[ "$mode" == "copy" ]]; then
                    echo "xsel --clipboard --input"
                else
                    echo "xsel --clipboard --output"
                fi
            else
                return 1
            fi
        else
            return 1
        fi
    else
        return 1
    fi
}

# ============================================================================
# File and Path Utilities
# ============================================================================

get_absolute_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        local dir=$(dirname "$path")
        local file=$(basename "$path")
        echo "$(cd "$dir" && pwd)/$file"
    else
        echo "$path"
    fi
}

ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || die "Failed to create directory: $dir"
    fi
}

# ============================================================================
# String Utilities
# ============================================================================

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

lowercase() {
    echo "$*" | tr '[:upper:]' '[:lower:]'
}

uppercase() {
    echo "$*" | tr '[:lower:]' '[:upper:]'
}

# ============================================================================
# Validation
# ============================================================================

is_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

is_valid_ip() {
    local ip="$1"
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ $ip =~ $regex ]]; then
        for octet in ${ip//./ }; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# ============================================================================
# Initialize
# ============================================================================

# Set up error trapping by default
setup_error_trap