# Wesley's dev environment installer for new Windows machines.
#
# This is a single-file portable installer. It installs everything
# needed to get the same dev environment as the host machine, then
# syncs the nix-config and Rio terminal config from a Git repo.
#
# Usage (PowerShell, run as Administrator):
#   iwr -useb https://raw.githubusercontent.com/<owner>/<repo>/main/install.ps1 | iex
#
# Or, after downloading:
#   .\install.ps1
#
# Requirements: Windows 10/11, internet, ~30 GB free disk.

[CmdletBinding()]
param(
    [string]$Repo = "ur-wesley/dotfiles",
    [string]$Branch = "main",
    [string]$NixConfigDir = "$HOME\nix-config",
    [switch]$SkipNixOS = $false,    # skip WSL NixOS install
    [switch]$SkipRepos = $false,     # skip git clone/fetch
    [switch]$SkipVSCode = $false,    # skip VS Code
    [switch]$SkipFonts = $false,     # skip fonts
    [switch]$Force = $false          # re-install everything
)

$ErrorActionPreference = "Stop"
$ProgressPreference   = "SilentlyContinue"

# ---- Pretty output -----------------------------------------------------
function Step($msg)   { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Ok($msg)     { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Warn($msg)   { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Fail($msg)   { Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Note($msg)   { Write-Host "  $msg" -ForegroundColor DarkGray }

# ---- Preflight: Admin --------------------------------------------------
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Fail "This installer must run as Administrator."
    exit 1
}

# ---- Preflight: winget -------------------------------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget is required. Install App Installer from the Microsoft Store."
    exit 1
}
Ok "winget found"

# ---- Preflight: WSL ---------------------------------------------------
if (-not $SkipNixOS) {
    $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
    if (-not $wsl) {
        Fail "WSL is required. Run: wsl --install"
        exit 1
    }
    Ok "wsl found"
}

# ---- Packages to install ---------------------------------------------
$wingetPackages = @(
    @{ id = "Microsoft.PowerShell";         name = "PowerShell 7" },
    @{ id = "Microsoft.VisualStudioCode";    name = "VS Code"; skip = $SkipVSCode },
    @{ id = "GitHub.cli";                    name = "GitHub CLI" },
    @{ id = "Schniz.fnm";                    name = "Fast Node Manager" },
    @{ id = "OpenJS.NodeJS.LTS";             name = "Node.js LTS" },
    @{ id = "GoLang.Go";                     name = "Go" },
    @{ id = "Rustlang.Rustup";               name = "Rust" },
    @{ id = "Python.Python.3.12";            name = "Python 3.12" },
    @{ id = "Microsoft.DotNet.SDK.9";        name = ".NET SDK 9" },
    @{ id = "PostgreSQL.PostgreSQL.16";      name = "PostgreSQL 16" },
    @{ id = "Git.Git";                       name = "Git" },
    @{ id = "Docker.DockerDesktop";          name = "Docker Desktop" },
    @{ id = "7zip.7zip";                     name = "7-Zip" },
    @{ id = "Notepad++.Notepad++";           name = "Notepad++" },
    @{ id = "voidtools.Everything";           name = "Everything Search" },
    @{ id = "jdxcode.mise";                   name = "mise (runtime manager, runs on Windows for use from PowerShell)" },
)

Step "Installing Windows packages via winget"
$failed = @()
foreach ($pkg in $wingetPackages) {
    if ($pkg.skip) { Note "skip $($pkg.name)"; continue }
    if (-not $Force) {
        $installed = winget list --id $pkg.id 2>$null | Select-String $pkg.id
        if ($installed) { Note "$($pkg.name) already installed"; continue }
    }
    Write-Host "  -> Installing $($pkg.name)..." -ForegroundColor DarkGray
    $args = @("install", "--id", $pkg.id, "--silent", "--accept-source-agreements", "--accept-package-agreements")
    $proc = Start-Process -FilePath "winget" -ArgumentList $args -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -ne 0) {
        Warn "Failed to install $($pkg.name) (winget exit $($proc.ExitCode))"
        $failed += $pkg
    } else {
        Ok "Installed $($pkg.name)"
    }
}
if ($failed.Count -gt 0) {
    Warn "Failed packages: $($failed.name -join ', ')"
}

# ---- Nerd Font ---------------------------------------------------------
if (-not $SkipFonts) {
    Step "Installing JetBrainsMono Nerd Font"
    if (-not (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\JetBrainsMonoNerdFont-Regular.ttf")) {
        Write-Host "  -> Installing via scoop bucket nerd-fonts..." -ForegroundColor DarkGray
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            scoop bucket add nerd-fonts 2>&1 | Out-Null
            scoop install JetBrainsMono-NF 2>&1 | Out-Null
            Ok "JetBrainsMono Nerd Font installed"
        } else {
            Warn "scoop not available; install JetBrainsMono Nerd Font manually"
        }
    } else {
        Note "JetBrainsMono Nerd Font already present"
    }
}

# ---- WSL NixOS install ------------------------------------------------
if (-not $SkipNixOS) {
    Step "Installing NixOS-WSL"
    $existing = wsl --list --quiet 2>&1 | Select-String "NixOS"
    if ($existing -and -not $Force) {
        Note "NixOS already registered"
    } else {
        $asset = Invoke-RestMethod "https://api.github.com/repos/nix-community/NixOS-WSL/releases/latest" `
            -Headers @{ "User-Agent" = "nix-config-installer" }
        $rootfs = $asset.assets | Where-Object { $_.name -match "nixos\.wsl$" } | Select-Object -First 1
        if (-not $rootfs) { Fail "Could not find nixos.wsl asset"; exit 1 }
        $tmp = Join-Path $env:TEMP "nixos.wsl"
        Write-Host "  -> Downloading $($rootfs.name)..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $rootfs.browser_download_url -OutFile $tmp -UseBasicParsing
        $sha = Invoke-WebRequest "$($rootfs.browser_download_url).sha256" -UseBasicParsing `
            | Select-Object -ExpandProperty Content
        $actual = (Get-FileHash $tmp -Algorithm SHA256).Hash.ToLower()
        if ($actual -ne $sha.Trim().Split()[0]) {
            Fail "NixOS rootfs SHA256 mismatch"; exit 1
        }
        New-Item -ItemType Directory -Path "C:\WSL\NixOS" -Force | Out-Null
        wsl --import NixOS "C:\WSL\NixOS" $tmp --version 2
        Remove-Item $tmp
        Ok "NixOS-WSL imported"

        # Set as default + apply wsl.conf
        wsl --set-default NixOS 2>&1 | Out-Null
        wsl -d NixOS -u root -- bash -c @'
set -euo pipefail
# wsl.conf
cat > /etc/wsl.conf <<'EOF'
[boot]
systemd=true
[user]
default=wesley
[interop]
enabled=true
appendWindowsPath=false
[automount]
enabled=true
options=metadata,umask=22,fmask=11
mountFsTab=true
[network]
generateHosts=true
generateResolvConf=true
EOF
# Create user
useradd -m -G wheel -s /nix/store/...placeholder.../fish  wesley 2>/dev/null \
  || useradd -m -G wheel -s "$(which fish)" wesley
echo "wesley ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopasswd
chmod 0440 /etc/sudoers.d/wheel-nopasswd
# First-boot fish-install on PATH
chsh -s "$(which fish)" wesley
'@
        Ok "NixOS-WSL configured"
    }
}

# ---- Clone nix-config -------------------------------------------------
if (-not $SkipRepos) {
    Step "Cloning nix-config to $NixConfigDir"
    if (Test-Path $NixConfigDir) {
        Push-Location $NixConfigDir
        git fetch --all
        git reset --hard "origin/$Branch"
        Pop-Location
        Ok "nix-config updated to origin/$Branch"
    } else {
        git clone "https://github.com/$Repo.git" $NixConfigDir
        Set-Location $NixConfigDir
        git checkout $Branch
        Ok "nix-config cloned"
    }

    # Windows Terminal settings (only adds NixOS profile if missing)
    Step "Patching Windows Terminal settings for NixOS"
    $wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $wtSettings) {
        Copy-Item $wtSettings "$wtSettings.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
        $json = Get-Content $wtSettings -Raw | ConvertFrom-Json
        $hasNix = $json.profiles.list | Where-Object { $_.name -eq "NixOS" -and -not $_.hidden } | Select-Object -First 1
        if (-not $hasNix) {
            Warn "NixOS profile not in Windows Terminal settings — please merge dotfiles/windows-terminal/settings.json manually"
        } else {
            Ok "Windows Terminal already has NixOS profile"
        }
    } else {
        Warn "Windows Terminal settings.json not found; skip"
    }
}

# ---- Done -------------------------------------------------------------
Step "Done. Next steps:"
Write-Host "  1. Open Windows Terminal (the NixOS profile drops you into fish in WSL)" -ForegroundColor Green
Write-Host "  2. Inside the WSL shell, run:" -ForegroundColor Green
Write-Host "       sudo nixos-rebuild switch --flake ~$HOME_USER/nix-config#nixos-wsl" -ForegroundColor Green
Write-Host "  3. After rebuild, the prompt + tools are live" -ForegroundColor Green
Write-Host ""
Write-Host "  Optional: VS Code extensions prune:" -ForegroundColor DarkGray
Write-Host "       code --list-extensions | ForEach-Object { code --uninstall-extension `$_ }" -ForegroundColor DarkGray
Write-Host ""
Ok "All set. Welcome to the new box."
