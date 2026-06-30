# Wesley's dev environment installer for new Windows machines.
#
# Single-file portable installer. Stow-driven dotfiles + NixOS-WSL.
# Mirrors the omerxx/dotfiles structure: one tree, one install command.
#
# Usage (PowerShell, run as Administrator):
#   iwr -useb https://raw.githubusercontent.com/<owner>/<repo>/main/install/install.ps1 | iex
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
    [switch]$SkipNixOS = $false,
    [switch]$SkipRepos = $false,
    [switch]$SkipVSCode = $false,
    [switch]$SkipFonts = $false,
    [switch]$SkipStow = $false,
    [switch]$SkipWinget = $false,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"
$ProgressPreference   = "SilentlyContinue"

# ---- Pretty output ----------------------------------------------------
function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Fail($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Note($msg) { Write-Host "  $msg" -ForegroundColor DarkGray }

# ---- Preflight: Admin -------------------------------------------------
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Fail "This installer must run as Administrator."
    exit 1
}

# ---- Preflight: winget ------------------------------------------------
if (-not $SkipWinget -and -not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget is required. Install App Installer from the Microsoft Store."
    exit 1
}
if (-not $SkipWinget) { Ok "winget found" }

# ---- Preflight: WSL ---------------------------------------------------
if (-not $SkipNixOS) {
    $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
    if (-not $wsl) {
        Fail "WSL is required. Run: wsl --install"
        exit 1
    }
    Ok "WSL found"
}

# ---- winget packages --------------------------------------------------
# Mirrors dotfiles/config/zellij (zellij default) + dotfiles/config/television
# + home/wesley/cli-tools.nix. Modern Unix CLI stack so PowerShell outside
# WSL feels like Linux.
$wingetPackages = @(
    # Dev environment
    @{ id = "Microsoft.PowerShell";         name = "PowerShell 7" },
    @{ id = "Microsoft.VisualStudioCode";    name = "VS Code"; skip = $SkipVSCode },
    @{ id = "GitHub.cli";                    name = "GitHub CLI" },
    @{ id = "Git.Git";                       name = "Git" },
    @{ id = "Docker.DockerDesktop";          name = "Docker Desktop" },

    # Language runtimes (mise still owns per-project versions, but
    # we install native ones for tooling outside WSL too).
    @{ id = "Schniz.fnm";                    name = "Fast Node Manager" },
    @{ id = "OpenJS.NodeJS.LTS";             name = "Node.js LTS" },
    @{ id = "GoLang.Go";                     name = "Go" },
    @{ id = "Rustlang.Rustup";               name = "Rust" },
    @{ id = "Python.Python.3.12";            name = "Python 3.12" },
    @{ id = "Microsoft.DotNet.SDK.9";        name = ".NET SDK 9" },

    # Runtime manager
    @{ id = "jdxcode.mise";                  name = "mise (runtime manager)" },

    # Terminals — WezTerm (Catppuccin Mocha, blur) is the GPU-accelerated
    # alternative to Rio (Rust, simpler). Both share dotfiles/config/<x>/.
    @{ id = "wez.wezterm";                   name = "WezTerm (GPU terminal)" },

    # Modern Unix CLI — fish-parity stack for PowerShell 7.
    # See dotfiles/home/powershell/Microsoft.PowerShell_profile.ps1
    @{ id = "gerardog.gsudo";                name = "gsudo (sudo for Windows)" },
    @{ id = "BurntSushi.ripgrep";            name = "ripgrep" },
    @{ id = "sharkdp.fd";                    name = "fd" },
    @{ id = "sharkdp.bat";                   name = "bat" },
    @{ id = "eza-community.eza";             name = "eza" },
    @{ id = "jqlang.jq";                     name = "jq" },
    @{ id = "junegunn.fzf";                  name = "fzf" },
    @{ id = "ajeetdsouza.zoxide";            name = "zoxide" },
    @{ id = "dandavison.delta";              name = "delta" },
    @{ id = "starship.starship";             name = "starship" },
    @{ id = "jesseduffield.lazygit";         name = "lazygit" },
    @{ id = "jesseduffield.lazydocker";      name = "lazydocker" },
    @{ id = "tldr-pages.tldr";               name = "tldr" },
    @{ id = "denisidoro.navi";               name = "navi" },
    @{ id = "atuinsh.atuin";                 name = "atuin" },

    # File management
    @{ id = "7zip.7zip";                     name = "7-Zip" },
)

if (-not $SkipWinget) {
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
}

# ---- scoop + stow -----------------------------------------------------
# Stow drives the dotfiles sync. Install via scoop so we have it on PATH.
if (-not $SkipStow) {
    Step "Installing GNU stow via scoop"
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  -> Installing scoop..." -ForegroundColor DarkGray
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri "https://get.scoop.sh" -UseBasicParsing | Invoke-Expression
    }
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop bucket add nerd-fonts 2>&1 | Out-Null
        scoop install stow 2>&1 | Out-Null
        Ok "stow installed"
    } else {
        Warn "scoop not available; install stow manually: scoop install stow"
    }
}

# ---- Nerd Font --------------------------------------------------------
if (-not $SkipFonts) {
    Step "Installing JetBrainsMono Nerd Font"
    if (-not (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\JetBrainsMonoNerdFont-Regular.ttf")) {
        Write-Host "  -> Installing via scoop bucket nerd-fonts..." -ForegroundColor DarkGray
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            scoop install JetBrainsMono-NF 2>&1 | Out-Null
            Ok "JetBrainsMono Nerd Font installed"
        } else {
            Warn "scoop not available; install JetBrainsMono Nerd Font manually"
        }
    } else {
        Note "JetBrainsMono Nerd Font already present"
    }
}

# ---- WSL NixOS install -----------------------------------------------
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

# ---- Clone nix-config ------------------------------------------------
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
}

# ---- Stow dotfiles ---------------------------------------------------
# Stow drops config/home into $HOME on Windows. Inside WSL, the same
# files are reached via the bind-mount of C:\Users\parac\nix-config
# (symlinked to ~/nix-config), and home-manager uses `xdg.configFile.source`
# to symlink ~/.config/<x> at Nix-store copies of the same files.
if (-not $SkipStow -and (Test-Path "$NixConfigDir\dotfiles")) {
    Step "Stowing dotfiles"
    Push-Location "$NixConfigDir\dotfiles"
    if (Get-Command stow -ErrorAction SilentlyContinue) {
        stow --target=$HOME --restow config home
        Ok "dotfiles stowed into $HOME"
    } else {
        Warn "stow not on PATH; skipping. Run: cd $NixConfigDir\dotfiles && stow --restow config home"
    }
    Pop-Location
}

# ---- NixOS rebuild inside WSL ----------------------------------------
if (-not $SkipNixOS -and -not $SkipRepos) {
    Step "Applying nixos-rebuild inside WSL"
    $wslStatus = wsl --list --verbose 2>&1 | Select-String "NixOS"
    if ($wslStatus) {
        wsl -d NixOS -u wesley -- bash -lc "cd ~ && sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl"
        if ($LASTEXITCODE -eq 0) {
            Ok "NixOS rebuild succeeded"
        } else {
            Warn "NixOS rebuild failed; check output above"
        }
    } else {
        Warn "NixOS distro not registered; run this script with -SkipNixOS:`$false`"
    }
}

# ---- Done ------------------------------------------------------------
Step "Done. Next steps:"
Write-Host "  1. Open Windows Terminal — the NixOS profile drops you into fish in WSL" -ForegroundColor Green
Write-Host "  2. From inside WSL, run 'zj' to start zellij (Catppuccin Mocha)" -ForegroundColor Green
Write-Host "  3. Press Ctrl+F to open television (fuzzy file finder)" -ForegroundColor Green
Write-Host "  4. Press Ctrl+G to open navi (cheatsheets)" -ForegroundColor Green
Write-Host ""
Write-Host "  Daily sync: cd $NixConfigDir\dotfiles && stow --restow config home" -ForegroundColor DarkGray
Write-Host "  Inside WSL: cd ~/nix-config/dotfiles && make restow" -ForegroundColor DarkGray
Write-Host ""
Ok "All set. Welcome to the new box."