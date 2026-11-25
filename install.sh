#!/usr/bin/env bash
# ==============================================================================
# ★ Kiseki Terminal (macOS) — One-Click Installer & Uninstaller
#   Target: macOS + Ghostty + Zsh / Oh My Zsh + Oh My Posh + Fastfetch
# ==============================================================================
set -euo pipefail

KISEKI_ROOT="${KISEKI_ROOT:-$HOME/.config/kiseki-terminal}"
KISEKI_REPO="${KISEKI_REPO:-xiruizhang675-cloud/kiseki-terminal-macos}"
DEFAULT_THEME="starlight-8bit"
ENABLE_CRT="off"
SKIP_TOOLS=0
UNINSTALL=0

ZSHRC="$HOME/.zshrc"
BAT_CONFIG="$HOME/.config/bat/config"
MARKER_START="# >>> Kiseki Terminal >>>"
MARKER_END="# <<< Kiseki Terminal <<<"
BACKUP_PREFIX="# [kiseki-backup] "

# --- Colors ---
C_CYAN='\033[1;36m'
C_MAG='\033[1;35m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'
C_DIM='\033[0;90m'
C_RESET='\033[0m'

info()  { printf "${C_CYAN}✦ %s${C_RESET}\n" "$*"; }
ok()    { printf "${C_GREEN}✔ %s${C_RESET}\n" "$*"; }
warn()  { printf "${C_YELLOW}▲ %s${C_RESET}\n" "$*"; }
err()   { printf "${C_RED}✖ %s${C_RESET}\n" "$*" >&2; }

usage() {
  cat <<EOF
Kiseki Terminal (macOS) Installer

Usage:
  ./install.sh [options]

Options:
  --theme <id>     Default theme to activate:
                   starlight-8bit (default) | nerv-eva | shinkai-rain | kyoto-sakura
  --crt            Enable subtle GLSL CRT phosphor bloom & scanline shader
  --skip-tools     Skip Homebrew installation of oh-my-posh, fastfetch, eza, bat
  --uninstall      Remove Kiseki Terminal config hooks and restore OMZ/P10k lines
  -h, --help       Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme)
      DEFAULT_THEME="${2:-}"
      shift 2
      ;;
    --crt)
      ENABLE_CRT="on"
      shift
      ;;
    --skip-tools)
      SKIP_TOOLS=1
      shift
      ;;
    --uninstall)
      UNINSTALL=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

case "$DEFAULT_THEME" in
  starlight-8bit|nerv-eva|shinkai-rain|kyoto-sakura) ;;
  *)
    err "Invalid theme '$DEFAULT_THEME'. Expected: starlight-8bit, nerv-eva, shinkai-rain, kyoto-sakura"
    exit 1
    ;;
esac

if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This installer is designed for macOS (Darwin)."
  exit 1
fi

detect_ghostty_config() {
  local c1="$HOME/.config/ghostty/config.ghostty"
  local c2="$HOME/.config/ghostty/config"
  local c3="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  if [[ -f "$c1" ]]; then
    printf '%s' "$c1"
  elif [[ -f "$c2" ]]; then
    printf '%s' "$c2"
  elif [[ -f "$c3" ]]; then
    printf '%s' "$c3"
  else
    printf '%s' "$c1"
  fi
}

strip_kiseki_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  awk -v start="$MARKER_START" -v end="$MARKER_END" '
    $0 == start { skip=1; next }
    $0 == end   { skip=0; next }
    !skip       { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

restore_backup_comments() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  awk -v pfx="$BACKUP_PREFIX" '
    $0 == "ZSH_THEME=\"\" # [kiseki-managed]" { next }
    index($0, pfx) == 1 { print substr($0, length(pfx) + 1); next }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

reload_ghostty() {
  if pgrep -x ghostty >/dev/null 2>&1; then
    pkill -USR2 -x ghostty 2>/dev/null || true
  fi
}

do_uninstall() {
  info "Uninstalling Kiseki Terminal (macOS)..."
  local gcfg
  gcfg="$(detect_ghostty_config)"

  local backup_dir="$HOME/.config/kiseki-backup-uninstall-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  [[ -f "$ZSHRC" ]] && cp -p "$ZSHRC" "$backup_dir/zshrc.pre-uninstall.bak"
  [[ -f "$gcfg" ]]  && cp -p "$gcfg"  "$backup_dir/ghostty.pre-uninstall.bak"

  strip_kiseki_block "$ZSHRC"
  restore_backup_comments "$ZSHRC"
  strip_kiseki_block "$gcfg"
  rm -rf "$KISEKI_ROOT"

  reload_ghostty
  ok "Kiseki Terminal removed cleanly."
  printf "${C_DIM}  Pre-uninstall snapshots saved in: %s${C_RESET}\n" "$backup_dir"
  printf "${C_CYAN}  Run 'exec zsh' (and Cmd+Shift+, in Ghostty) to refresh your shell.${C_RESET}\n"
}

if [[ "$UNINSTALL" -eq 1 ]]; then
  do_uninstall
  exit 0
fi

# --- 0. Locate or Download Source Repository ---
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

TEMP_CLONE=""
cleanup() {
  if [[ -n "$TEMP_CLONE" && -d "$TEMP_CLONE" ]]; then
    rm -rf "$TEMP_CLONE"
  fi
}
trap cleanup EXIT

REPO_ROOT="$SCRIPT_DIR"
if [[ -z "$REPO_ROOT" || ! -d "$REPO_ROOT/themes" || ! -d "$REPO_ROOT/ghostty-themes" ]]; then
  if [[ -z "$KISEKI_REPO" ]]; then
    err "Could not find local themes/ directory. Clone the repository first or set KISEKI_REPO=<owner>/<repo>."
    exit 1
  fi
  TEMP_CLONE="$(mktemp -d)"
  info "[0/5] Downloading Kiseki Terminal from github.com/$KISEKI_REPO..."
  curl -fsSL "https://github.com/$KISEKI_REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$TEMP_CLONE"
  REPO_ROOT="$(find "$TEMP_CLONE" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
fi

printf "\n${C_MAG}★ Installing Kiseki Terminal for macOS + Ghostty...${C_RESET}\n"

# --- 1. Timestamped Backup ---
GHOSTTY_CFG="$(detect_ghostty_config)"
BACKUP_DIR="$HOME/.config/kiseki-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
[[ -f "$ZSHRC" ]]       && cp -p "$ZSHRC" "$BACKUP_DIR/zshrc.bak"
[[ -f "$GHOSTTY_CFG" ]] && cp -p "$GHOSTTY_CFG" "$BACKUP_DIR/ghostty.conf.bak"
[[ -f "$BAT_CONFIG" ]]  && cp -p "$BAT_CONFIG" "$BACKUP_DIR/bat-config.bak"
ok "[1/5] Backup saved to $BACKUP_DIR"

# --- 2. Copy Themes, Ghostty Configs, Shaders, and Zsh Engine ---
mkdir -p "$KISEKI_ROOT/scripts" "$KISEKI_ROOT/shaders" "$KISEKI_ROOT/ghostty-themes"
cp -R "$REPO_ROOT/themes" "$KISEKI_ROOT/"
cp -R "$REPO_ROOT/ghostty-themes" "$KISEKI_ROOT/"
cp -R "$REPO_ROOT/shaders" "$KISEKI_ROOT/"
cp -R "$REPO_ROOT/scripts" "$KISEKI_ROOT/"
[[ -f "$REPO_ROOT/version.json" ]] && cp "$REPO_ROOT/version.json" "$KISEKI_ROOT/version.json"

if [[ ! -f "$BAT_CONFIG" ]]; then
  mkdir -p "$(dirname "$BAT_CONFIG")"
  cat > "$BAT_CONFIG" <<'EOF'
--style="numbers,changes,header,grid"
--italic-text=always
--paging=auto
EOF
fi
ok "[2/5] Installed 4 anime themes & macOS engine to $KISEKI_ROOT"

# --- 3. Install CLI Dependencies via Homebrew ---
if [[ "$SKIP_TOOLS" -eq 0 ]]; then
  if command -v brew >/dev/null 2>&1; then
    missing=()
    command -v oh-my-posh >/dev/null 2>&1 || missing+=("jandedobbeleer/oh-my-posh/oh-my-posh")
    command -v fastfetch  >/dev/null 2>&1 || missing+=("fastfetch")
    command -v eza        >/dev/null 2>&1 || missing+=("eza")
    command -v bat        >/dev/null 2>&1 || missing+=("bat")

    if [[ ${#missing[@]} -gt 0 ]]; then
      info "[3/5] Installing missing tools via Homebrew: ${missing[*]}"
      brew install "${missing[@]}"
    else
      ok "[3/5] All recommended CLI tools already installed"
    fi
  else
    warn "[3/5] Homebrew not found. Install oh-my-posh, fastfetch, eza, bat manually."
  fi
else
  info "[3/5] Skipped CLI tools install (--skip-tools)"
fi

# --- 4. Configure Ghostty (Non-Destructive config-file Hook) ---
mkdir -p "$(dirname "$GHOSTTY_CFG")"
touch "$GHOSTTY_CFG"
strip_kiseki_block "$GHOSTTY_CFG"
cat >> "$GHOSTTY_CFG" <<EOF

$MARKER_START
# Dynamically managed by $KISEKI_ROOT/scripts/kiseki.zsh
config-file = ?$KISEKI_ROOT/ghostty-active.conf
$MARKER_END
EOF

printf '%s' "$DEFAULT_THEME" > "$KISEKI_ROOT/current-theme.txt"
printf '%s' "$ENABLE_CRT"    > "$KISEKI_ROOT/crt-mode.txt"

zsh -c "
  export NO_FETCH=1
  export KISEKI_ROOT='$KISEKI_ROOT'
  source '$KISEKI_ROOT/scripts/kiseki.zsh'
  _kiseki_sync_ghostty '$DEFAULT_THEME'
"
ok "[4/5] Configured Ghostty ($GHOSTTY_CFG) with theme '$DEFAULT_THEME'"

# --- 5. Safely Wire ~/.zshrc (OMZ + Powerlevel10k Compatible) ---
touch "$ZSHRC"
strip_kiseki_block "$ZSHRC"

# Safely disable existing ZSH_THEME & Powerlevel10k so Oh My Posh owns the prompt layer
# while preserving all Oh My Zsh plugins and completions.
tmp_zshrc="$(mktemp)"
awk -v pfx="$BACKUP_PREFIX" '
  # Already managed
  $0 == "ZSH_THEME=\"\" # [kiseki-managed]" { print; next }
  # Inside a multi-line p10k-instant-prompt if...fi block
  in_p10k_if {
    print pfx $0
    if ($0 ~ /^[[:space:]]*fi([[:space:]]|$)/) in_p10k_if = 0
    next
  }
  # Start of multi-line p10k-instant-prompt if block
  $0 !~ /^[[:space:]]*#/ && /p10k-instant-prompt/ && /^[[:space:]]*if[[:space:]]/ {
    in_p10k_if = 1
    print pfx $0
    next
  }
  # Non-empty ZSH_THEME="..." -> comment out & inject empty ZSH_THEME
  /^[[:space:]]*ZSH_THEME=/ && $0 !~ /^[[:space:]]*ZSH_THEME=(""|\x27\x27)[[:space:]]*(#.*)?$/ {
    print pfx $0
    print "ZSH_THEME=\"\" # [kiseki-managed]"
    next
  }
  # Single-line Powerlevel10k ~/.p10k.zsh source lines
  $0 !~ /^[[:space:]]*#/ && (/(\.p10k\.zsh|p10k-instant-prompt)/) {
    print pfx $0
    next
  }
  { print }
' "$ZSHRC" > "$tmp_zshrc"
mv "$tmp_zshrc" "$ZSHRC"

cat >> "$ZSHRC" <<EOF

$MARKER_START
# Loaded AFTER Oh My Zsh so prompt, eza/bat aliases, and fastfetch never conflict.
[[ -f "$KISEKI_ROOT/scripts/kiseki.zsh" ]] && source "$KISEKI_ROOT/scripts/kiseki.zsh"
$MARKER_END
EOF
ok "[5/5] Updated $ZSHRC (Oh My Zsh plugins & completions preserved)"

reload_ghostty

printf "\n${C_GREEN}★ Kiseki Terminal (macOS) installation complete!${C_RESET}\n"
printf "  Active theme : ${C_MAG}%s${C_RESET} (CRT: %s)\n" "$DEFAULT_THEME" "$ENABLE_CRT"
printf "  Backup dir   : ${C_DIM}%s${C_RESET}\n" "$BACKUP_DIR"
printf "  Next step    : Press ${C_CYAN}Cmd+Shift+,${C_RESET} in Ghostty and run ${C_CYAN}exec zsh${C_RESET}\n"
printf "  Commands     : ${C_CYAN}themes${C_RESET} | ${C_CYAN}theme <id>${C_RESET} | ${C_CYAN}crt${C_RESET} | ${C_CYAN}termbg${C_RESET} | ${C_CYAN}termfont${C_RESET} | ${C_CYAN}fetch${C_RESET}\n\n"
