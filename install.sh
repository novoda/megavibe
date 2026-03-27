#!/bin/bash
set -euo pipefail

# Megavibe — one-command install for Linux
# Usage: curl -fsSL https://raw.githubusercontent.com/novoda/megavibe/main/install.sh | bash
#
# Designed for first-time terminal users:
# - Auto-installs Node.js, git, jq, python3 if missing
# - Guides through each login step interactively
# - Friendly output with clear next steps

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
DIM='\033[2m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}done${RESET} $1"; }
info() { echo -e "${BOLD}$1${RESET}"; }
warn() { echo -e "  ${YELLOW}!${RESET} $1"; }

echo ""
echo -e "${BOLD}Welcome to Megavibe${RESET}"
echo -e "${DIM}Give Claude Code a memory that never dies.${RESET}"
echo ""

# ─── OS check ────────────────────────────────────────────────────────

if [[ "$(uname)" != "Linux" ]]; then
  echo -e "${RED}This script only supports Linux.${RESET}"
  exit 1
fi

# ─── Detect package manager ───────────────────────────────────────────

if command -v apt-get &>/dev/null; then
  PKG_INSTALL="sudo apt-get install -y"
  PKG_UPDATE="sudo apt-get update -y"
elif command -v dnf &>/dev/null; then
  PKG_INSTALL="sudo dnf install -y"
  PKG_UPDATE="sudo dnf makecache"
elif command -v pacman &>/dev/null; then
  PKG_INSTALL="sudo pacman -S --noconfirm"
  PKG_UPDATE="sudo pacman -Sy"
else
  echo -e "${RED}Unsupported package manager. Please install node, jq, and python3 manually.${RESET}"
  exit 1
fi

# ─── Prerequisites (auto-install everything) ─────────────────────────

info "Step 1 of 4: Checking prerequisites"
echo ""

# Update package index
echo "  Updating package index..."
$PKG_UPDATE &>/dev/null

# git
if ! command -v git &>/dev/null; then
  echo "  Installing git..."
  $PKG_INSTALL git
  ok "git"
else
  ok "git (already installed)"
fi

# Node.js (for npm/npx, needed by MCP servers)
if ! command -v node &>/dev/null; then
  echo "  Installing Node.js..."
  $PKG_INSTALL nodejs npm
  ok "Node.js $(node --version)"
else
  ok "Node.js $(node --version) (already installed)"
fi

# jq (needed by hooks)
if ! command -v jq &>/dev/null; then
  echo "  Installing jq..."
  $PKG_INSTALL jq
  ok "jq"
else
  ok "jq (already installed)"
fi

# Python 3 (for poma-memory)
if ! command -v python3 &>/dev/null; then
  echo "  Installing Python 3..."
  $PKG_INSTALL python3
  ok "Python $(python3 --version 2>&1 | cut -d' ' -f2)"
else
  ok "Python $(python3 --version 2>&1 | cut -d' ' -f2) (already installed)"
fi

echo ""

# ─── Clone and run setup ─────────────────────────────────────────────

info "Step 2 of 4: Installing Megavibe"
echo ""

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "  Downloading..."
git clone --depth 1 https://github.com/poma-ai/megavibe.git "$TMPDIR/megavibe" 2>/dev/null
echo ""

# Run setup (installs CLIs, MCP servers, protocol, statusline)
bash "$TMPDIR/megavibe/setup.sh"

echo ""

# ─── Login guidance ──────────────────────────────────────────────────

info "Step 3 of 4: Sign in to AI services"
echo ""
echo "  Megavibe uses Claude as the main brain, with Gemini and ChatGPT"
echo "  as helpers. You need at least a Claude subscription."
echo ""
echo -e "  ${BOLD}Required:${RESET}"
echo "    Claude Code  — you should already be logged in"
echo "                   (if not, run: claude)"
echo ""
echo -e "  ${BOLD}Optional but recommended:${RESET}"
echo "    Gemini       — run: gemini"
echo "    ChatGPT      — run: codex"
echo ""
echo -e "  ${DIM}Each command opens your browser to sign in. Free tiers work.${RESET}"
echo -e "  ${DIM}You can add these later — megavibe works without them.${RESET}"
echo ""
read -p "  Press Enter when ready to continue... "
echo ""

# ─── Done ────────────────────────────────────────────────────────────

info "Step 4 of 4: Ready!"
echo ""
echo -e "  ${GREEN}${BOLD}Megavibe is installed.${RESET}"
echo ""
echo "  To start using it, open your project folder and run megavibe:"
echo ""
echo -e "    ${BOLD}cd ~/Desktop/my-project${RESET}    ${DIM}(or wherever your code is)${RESET}"
echo -e "    ${BOLD}megavibe${RESET}"
echo ""
echo "  That's it. Claude will remember everything from now on."
echo ""
echo -e "  ${DIM}Tip: Run 'megavibe' every time you start working. It's always safe to re-run.${RESET}"
echo ""
