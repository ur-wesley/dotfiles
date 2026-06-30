#!/usr/bin/env bash
# update.sh — Apply dotfile + Nix changes to the current WSL session.
#
# What this does, in order:
#   1. git pull the latest dotfiles + Nix config
#   2. nixos-rebuild switch — build the new generation
#   3. Switch the home-manager profile to the new generation
#   4. Run the activation script as the user (the systemd unit runs as
#      root and fails on NixOS-WSL)
#   5. Force-relink every ~/.config/* symlink so it points at the
#      latest home-manager-files store path. This is the critical step
#      that `nrs` alone doesn't do — home-manager's `linkGeneration`
#      skips symlinks that already exist, so content edits don't show
#      up until you blow the symlinks away.
#
# Usage:
#   ./update.sh                # full update: git pull + nrs + relink
#   ./update.sh --no-pull      # skip git pull (offline, or working tree dirty)
#   ./update.sh --relink-only  # just refresh ~/.config/* symlinks
#
# After this finishes:
#   - Starship / zellij / tv configs pick up immediately
#   - New fish/zsh/bash aliases need `exec fish` to reload
#   - Windows-side changes (Rio, Windows Terminal, PowerShell profile)
#     need `stow --restow config home` from PowerShell — see
#     install/sync.ps1.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

DO_PULL=true
RELINK_ONLY=false
for arg in "$@"; do
    case "$arg" in
        --no-pull)     DO_PULL=false ;;
        --relink-only) DO_PULL=false; RELINK_ONLY=true ;;
        -h|--help)
            sed -n '2,28p' "$0" | sed 's/^# \?//'
            exit 0 ;;
        *) echo "Unknown flag: $arg"; exit 2 ;;
    esac
done

step() { printf '\n\033[1;36m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '  \033[1;33m[WARN]\033[0m %s\n' "$*"; }
fail() { printf '  \033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

# ---- 1. git pull ----------------------------------------------------
if $DO_PULL; then
    step "Pulling latest"
    if git remote get-url origin >/dev/null 2>&1; then
        if ! git pull --rebase --autostash; then
            fail "git pull failed — resolve conflicts and rerun"
        fi
        ok "Updated to $(git rev-parse --short HEAD)"
    else
        warn "No remote configured — skipping"
    fi
fi

# ---- 2. nixos-rebuild switch ----------------------------------------
if ! $RELINK_ONLY; then
    step "Rebuilding NixOS (this takes a minute)"
    if [ "$(id -u)" -ne 0 ] && ! command -v sudo >/dev/null; then
        fail "Need root or sudo for nixos-rebuild"
    fi
    sudo -n nixos-rebuild switch --flake "$REPO_DIR#nixos-wsl" 2>&1 | tail -25 \
        || warn "nixos-rebuild had errors — check the output above"
fi

# ---- 3. Find the new generation ------------------------------------
# The systemd service unit's ExecStart gives us the canonical path.
step "Detecting new home-manager generation"
NEW_GEN=""
for f in /etc/systemd/system/home-manager-wesley.service \
         /run/systemd/system/home-manager-wesley.service; do
    if [ -f "$f" ]; then
        NEW_GEN=$(grep -oP '/nix/store/[^ ]+home-manager-generation' "$f" | head -1 || true)
        [ -n "$NEW_GEN" ] && break
    fi
done
if [ -z "$NEW_GEN" ] || [ ! -d "$NEW_GEN" ]; then
    fail "Could not find new home-manager-generation path. Run nrs manually first."
fi
ok "New generation: $NEW_GEN"

# Set the profile (so 'home-manager switch' works later)
nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --set "$NEW_GEN" \
    || warn "Could not update home-manager profile"

# ---- 4. Run activation as user --------------------------------------
step "Running home-manager activation"
HM_SETUP_ENV=$(grep -oP '/nix/store/[^ ]+hm-setup-env' /etc/systemd/system/home-manager-wesley.service 2>/dev/null | head -1)
if [ -z "$HM_SETUP_ENV" ]; then
    HM_SETUP_ENV="/nix/store/029g69vs1qf2fcpqlfcv5qgfyp45yv41-hm-setup-env"
fi
"$HM_SETUP_ENV" "$NEW_GEN" \
    || warn "Activation script exited non-zero — check 'journalctl -xeu home-manager-wesley.service'"

# ---- 5. Force-relink stale symlinks ---------------------------------
step "Force-relinking ~/.config/* to new generation"
ACTIVE_FILES=$(readlink -f "$NEW_GEN/home-files" 2>/dev/null || echo "")
if [ -z "$ACTIVE_FILES" ] || [ ! -d "$ACTIVE_FILES/.config" ]; then
    fail "Could not resolve home-files for $NEW_GEN"
fi
ok "Active home-manager-files: $ACTIVE_FILES"

# Walk every file in the active generation's .config and recreate the
# matching symlink under ~/.config. Stale symlinks get blown away.
#
# Note: use `-type l` not `-type f` — the Nix store's .config/* entries
# are symlinks (to /nix/store/*-hm_<name>), not regular files.
COUNT=0
while IFS= read -r -d '' src; do
    rel="${src#$ACTIVE_FILES/.config/}"
    dest="$HOME/.config/$rel"
    mkdir -p "$(dirname "$dest")"
    rm -f "$dest"
    ln -sfn "$src" "$dest"
    COUNT=$((COUNT + 1))
done < <(find "$ACTIVE_FILES/.config" -type l -print0 2>/dev/null)
ok "Relinked $COUNT files under ~/.config/"

# home.file."<path>" entries outside ~/.config/ — explicit list
# (home-manager doesn't preserve a 1:1 tree outside .config/).
declare -A HOME_FILE_MAP=(
    ["$HOME/.config/git/ignore"]="$ACTIVE_FILES/.config/git/ignore"
    ["$HOME/.config/git/attributes"]="$ACTIVE_FILES/.config/git/attributes"
)
for dest in "${!HOME_FILE_MAP[@]}"; do
    src="${HOME_FILE_MAP[$dest]}"
    [ -e "$src" ] || continue
    mkdir -p "$(dirname "$dest")"
    rm -f "$dest"
    ln -sfn "$src" "$dest"
done

# ---- 6. Done --------------------------------------------------------
step "Update complete"
cat <<'EOF'

  Starship + zellij + tv configs are now live (open a new shell to see).

  IMPORTANT: if you were inside a zellij session, the new config
  (default_shell fish, default_terminal alacritty, pane_frames false)
  does NOT apply to that session — only to NEW sessions.
  Run: zellij kill-all-sessions -y  (then zj to re-attach)

  Windows-side changes (Rio, Windows Terminal, PowerShell profile) need:
    PowerShell> stow --restow config home
  Or just run install/sync.ps1 — it does stow + nixos-rebuild together.

  New fish/zsh/bash aliases need:
    exec fish     (or close + reopen the terminal)
EOF
ok "Done."