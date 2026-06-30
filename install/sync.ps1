# Wesley's config sync — stow-driven, omerxx-style.
# Run from PowerShell (no admin needed). Will:
#   1. git pull in the nix-config repo
#   2. stow --restow config home into $HOME (Windows-side)
#   3. trigger nixos-rebuild inside WSL (Linux-side)
#
# Inside WSL, run: cd ~/nix-config/dotfiles && make restow && nrs

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

# 1. Git pull
Step "Updating nix-config in $NixConfigDir"
if (-not (Test-Path $NixConfigDir)) {
    git clone "https://github.com/$Repo.git" $NixConfigDir
    Set-Location $NixConfigDir
    git checkout $Branch
} else {
    Push-Location $NixConfigDir
    git fetch --all
    git reset --hard "origin/$Branch"
    Pop-Location
}
Ok "nix-config is on origin/$Branch"

# 2. Stow Windows-side dotfiles
Step "Stowing dotfiles into $HOME"
$dotfilesDir = Join-Path $NixConfigDir "dotfiles"
if (Test-Path $dotfilesDir) {
    Push-Location $dotfilesDir
    if (Get-Command stow -ErrorAction SilentlyContinue) {
        stow --target=$HOME --restow config home
        Ok "stow --restow config home → $HOME"
    } else {
        Warn "stow not on PATH. Install via: scoop install stow"
    }
    Pop-Location
} else {
    Warn "$dotfilesDir not found; skipping stow"
}

# 3. NixOS rebuild inside WSL (the Linux-side apply)
Step "Applying nixos-rebuild inside WSL"
$wslStatus = wsl --list --verbose 2>&1 | Select-String "NixOS"
if ($wslStatus) {
    # Inside WSL, the dotfiles are reached via ~/nix-config (symlink to
    # C:\Users\parac\nix-config). Home-manager uses xdg.configFile.source
    # to read from dotfiles/config/* and rebuilds.
    wsl -d NixOS -u wesley -- bash -lc "cd ~/nix-config/dotfiles && make restow && cd ~ && sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl"
    if ($LASTEXITCODE -eq 0) {
        Ok "NixOS rebuild succeeded"
    } else {
        Warn "NixOS rebuild failed; check output above"
    }
} else {
    Warn "NixOS distro not registered; run install.ps1 first"
}

Ok "Sync complete. Restart your terminal to pick up changes."
Write-Host ""
Write-Host "  Inside WSL, the daily workflow is:" -ForegroundColor DarkGray
Write-Host "    cd ~/nix-config/dotfiles && make restow" -ForegroundColor DarkGray
Write-Host "    nrs                                            # rebuild nix" -ForegroundColor DarkGray