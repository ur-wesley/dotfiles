# Wesley's Windows-side dotfiles sync -- pulls latest + restows.
#
# Mirrors dotfiles/update.sh for Windows. Use this to apply Rio,
# Windows Terminal, PowerShell profile changes from the repo to
# your Windows profile.
#
# Usage (from PowerShell, any working dir):
#   irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/update.ps1 | iex
#   # OR
#   .\update.ps1
#
# Requires: scoop with `stow` installed (install.ps1 handles this).

[CmdletBinding()]
param(
    [string]$Repo = "ur-wesley/dotfiles",
    [string]$Branch = "main",
    [string]$NixConfigDir = "$HOME\nix-config"
)

$ErrorActionPreference = "Stop"
function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red; exit 1 }

# 1. git pull
Step "Pulling latest"
if (Test-Path $NixConfigDir) {
    Push-Location $NixConfigDir
    git fetch --all
    git reset --hard "origin/$Branch"
    Pop-Location
    Ok "Updated to $(git -C $NixConfigDir rev-parse --short HEAD)"
} else {
    Fail "$NixConfigDir not found. Run install.ps1 first."
}

# 2. Check stow
Step "Checking stow"
if (-not (Get-Command stow -ErrorAction SilentlyContinue)) {
    Fail "stow not on PATH. Install: scoop install stow"
}
Ok "stow available"

# 3. Restow config + home
Step "Restowing dotfiles into $HOME"
Push-Location "$NixConfigDir\dotfiles"
$configDir = "$NixConfigDir\dotfiles"
& stow --target=$HOME --dir=$configDir --restow config home
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Fail "stow failed"
}
Pop-Location
Ok "config + home restowed"

# 4. WSL rebuild (if WSL is set up)
Step "Triggering nixos-rebuild in WSL"
$wslStatus = wsl --list --verbose 2>&1 | Select-String "NixOS"
if ($wslStatus) {
    wsl -d NixOS -u wesley -- bash -lc "~/nix-config/dotfiles/update.sh --no-pull" 2>&1 | Select-Object -Last 20
} else {
    Warn "WSL NixOS not registered; skipping nixos-rebuild"
}

Step "Done"
Write-Host ""
Write-Host "  Restart Rio / Windows Terminal to pick up the new config." -ForegroundColor Green
Write-Host "  Inside WSL: exec fish  (or close + reopen terminal)." -ForegroundColor DarkGray
Write-Host ""
Ok "Update complete."