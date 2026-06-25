# Wesley's config sync — pulls latest nix-config and reapplies
# Run from PowerShell as Administrator. Will:
#   1. git pull in the nix-config repo
#   2. Sync Rio + Windows Terminal + mise + navi configs
#   3. Trigger nixos-rebuild inside the WSL distro

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

# 2. Windows Terminal (only if user wants to replace)
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

# 2b. Rio config
Step "Syncing Rio config"
$rioDir = "$env:LOCALAPPDATA\rio"
New-Item -ItemType Directory -Path $rioDir -Force | Out-Null
Copy-Item "$NixConfigDir\dotfiles\rio\config.toml" "$rioDir\config.toml" -Force
Ok "Rio config synced"

# 2c. mise config (language runtimes via mise, not Nix)
Step "Syncing mise config"
$miseDir = "$env:USERPROFILE\.config\mise"
New-Item -ItemType Directory -Path $miseDir -Force | Out-Null
Copy-Item "$NixConfigDir\dotfiles\mise\config.toml" "$miseDir\config.toml" -Force
Ok "mise config synced (run 'mise install' to pick up new tools)"

# 2d. navi cheatsheets (Linux + Windows; navi merges them all)
Step "Syncing navi cheatsheets"
$naviDir = "$env:USERPROFILE\.config\navi"
New-Item -ItemType Directory -Path $naviDir -Force | Out-Null
if (Test-Path "$NixConfigDir\dotfiles\navi") {
    Get-ChildItem -Path "$NixConfigDir\dotfiles\navi" -File | ForEach-Object {
        Copy-Item $_.FullName -Destination $naviDir -Force
    }
}
Ok "navi cheatsheets synced"

# 3. NixOS rebuild inside WSL
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

Ok "Sync complete. Restart your terminal to pick up changes."
