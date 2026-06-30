#!/usr/bin/env bash
# stow.sh — bash wrapper around GNU stow with sensible defaults.
# Works on Linux, macOS, and inside WSL. Falls back to scoop-installed
# stow on Windows when called from PowerShell.
#
# Usage:
#   ./stow.sh                    # restow all packages
#   ./stow.sh stow               # stow all packages
#   ./stow.sh unstow             # remove all stow symlinks
#   ./stow.sh restow config home # restow specific packages
#   ./stow.sh adopt              # turn real files into symlinks

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME:-/root}"
ACTION="${1:-restow}"
shift || true
PACKAGES="${@:-config home}"

# Find stow binary
STOW_BIN="$(command -v stow 2>/dev/null || true)"
if [ -z "$STOW_BIN" ]; then
    echo "[stow.sh] GNU stow not found on PATH." >&2
    echo "[stow.sh] Install: brew install stow (macOS) | sudo apt install stow (Linux) | scoop install stow (Windows)" >&2
    exit 1
fi

case "$ACTION" in
    stow)    FLAGS="--target=$TARGET --dir=$DOTFILES_DIR" ;;
    unstow)  FLAGS="--target=$TARGET --dir=$DOTFILES_DIR --delete" ;;
    restow)  FLAGS="--target=$TARGET --dir=$DOTFILES_DIR --restow" ;;
    adopt)   FLAGS="--target=$TARGET --dir=$DOTFILES_DIR --adopt" ;;
    *)
        echo "[stow.sh] Unknown action: $ACTION" >&2
        echo "[stow.sh] Valid: stow | unstow | restow | adopt" >&2
        exit 2
        ;;
esac

echo "[stow.sh] $ACTION → $TARGET ($PACKAGES)"
exec "$STOW_BIN" $FLAGS $PACKAGES