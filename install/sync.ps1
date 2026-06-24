# Wesley's config sync — pulls latest nix-config and reapplies
# Run from PowerShell as Administrator. Will:
#   1. git pull in the nix-config repo
#   2. Sync WezTerm config to ~/.config/wezterm/
#   3. Sync Windows Terminal settings
#   4. Trigger nixos-rebuild inside the WSL distro

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

# 2. WezTerm
Step "Syncing WezTerm config"
$wtDir = "$env:USERPROFILE\.config\wezterm"
New-Item -ItemType Directory -Path $wtDir -Force | Out-Null
Copy-Item "$NixConfigDir\dotfiles\wezterm\wezterm.lua" "$wtDir\wezterm.lua" -Force
Ok "WezTerm config synced"

# 3. Windows Terminal (only if user wants to replace)
Step "Checking Windows Terminal settings"
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path "$NixConfigDir\dotfiles\windows-terminal\settings.json") {
    if (Test-Path $wtSettings) {
        $existingJson = Get-Content $wtSettings -Raw | ConvertFrom-Json
        $hasNix = $existingJson.profiles.list | Where-Object { $_.name -eq "NixOS" -and -not $_.hidden } | Select-Object -First 1
        if ($hasNix) {
            Ok "Windows Terminal already has NixOS profile (no action needed)"
        } else {
            Warn "NixOS profile not in Windows Terminal — see dotfiles/windows-terminal/settings.json"
        }
    }
}

# 4. NixOS rebuild inside WSL
Step "Applying NixOS rebuild inside WSL"
$wslStatus = wsl --list --verbose 2>&1 | Select-String "NixOS"
if ($wslStatus) {
    wsl -d NixOS -u wesley -- bash -lc "cd ~ && sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl"
    if ($LASTEXITCODE -eq 0) {
        Ok "NixOS rebuild succeeded"
    } else {
        Warn "NixOS rebuild failed; check output above"
    }
} else {
    Warn "NixOS distro not registered; run install.ps1 first"
}

Ok "Sync complete. Restart WezTerm to pick up changes."
