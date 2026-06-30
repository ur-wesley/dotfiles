# nix-config

Wesley's dotfiles — NixOS-WSL + stow-driven Windows-side config. Single
source of truth for the entire dev environment on this Windows box:
shell, editor, terminal, dev tools, and dotfiles.

The repo lives at `C:\Users\parac\nix-config` on the Windows side and
is symlinked from `~/nix-config` inside WSL so both sides see the same
files.

## Quick start

### On a fresh Windows machine

```powershell
# Right-click PowerShell, "Run as Administrator"
irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/install.ps1 | iex
```

This installs winget packages (PowerShell 7, VS Code, dev CLIs, etc.),
scoop + stow, JetBrainsMono Nerd Font, NixOS-WSL, and stows the
dotfiles into `$HOME`. After it finishes:

1. Open Windows Terminal — the NixOS profile drops you into fish in WSL.
2. Inside the WSL shell, run `nrs` (alias for `sudo nixos-rebuild switch`).
3. Done. Zellij + television + navi + fish + starship all live.

### Daily sync (Windows)

```powershell
irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/sync.ps1 | iex
```

Pulls latest, restows on Windows, rebuilds NixOS in WSL.

### Daily sync (inside WSL)

```fish
cd ~/nix-config/dotfiles
make restow
nrs
```

`make restow` is `stow --restow config home` — handles file moves
cleanly. After edits to `dotfiles/config/*` files, run it before
`nrs` so home-manager picks up the new content.

## Structure

omerxx-style: a single tree, each tool gets a subdirectory mirroring
its target location. Stow turns the tree into symlinks in `$HOME`.

```
nix-config/
├── flake.nix                       # NixOS-WSL flake (NixOS 26.05 unstable + home-manager + Nixvim)
├── flake.lock                      # auto-generated
├── README.md                       # you are here
├── .gitattributes                  # line-ending policy (LF)
├── install/
│   ├── install.ps1                 # one-shot Windows installer (winget + scoop + stow + WSL)
│   ├── install.bat                 # .bat wrapper for double-click
│   └── sync.ps1                    # pull latest + restow + nixos-rebuild
├── dotfiles/                       # stow-driven dotfiles (shared Nix ↔ Windows)
│   ├── Makefile                    # make stow | unstow | restow | adopt
│   ├── stow.sh                     # bash wrapper around stow
│   ├── config/                     # → ~/.config/* via `stow --target=$HOME config`
│   │   ├── git/{config,ignore,attributes}
│   │   ├── mise/config.toml
│   │   ├── navi/welcome.yaml
│   │   ├── starship/starship.toml  # Catppuccin Mocha, rounded pills
│   │   ├── television/{config.toml,channels/}
│   │   ├── windows-terminal/settings.json
│   │   └── zellij/{config.yaml,themes/,layouts/}
│   └── home/                       # → ~/* via `stow --target=$HOME home`
│       └── powershell/Microsoft.PowerShell_profile.ps1
└── home/wesley/                    # home-manager modules (Nix-side, read dotfiles/config/*)
    ├── core.nix                    # starship, fzf, zoxide, direnv, atuin, mcfly
    ├── fish.nix                    # fish shell + aliases + functions + binds
    ├── git.nix                     # git + delta + gh + lazygit (sources dotfiles/config/git)
    ├── zellij.nix                  # programs.zellij + xdg.configFile sources
    ├── television.nix              # programs.television + xdg.configFile sources
    ├── terminal.nix                # btop, yazi, broot, glow, mosh, trash-cli
    ├── cli-tools.nix               # eza, bat, ripgrep, fd, jq, yq, k9s, dive, …
    ├── dev-tools.nix               # docker, k8s CLIs, build tools, opencode, gentle-ai
    ├── zsh.nix                     # zsh fallback shell
    ├── bash.nix                    # bash fallback shell
    └── nvim.nix                    # Nixvim (full editor config)
```

### The Nix ↔ Windows dotfiles pattern

Each file in `dotfiles/config/` is a single source of truth:

- **Windows side**: stow symlinks it directly into `%USERPROFILE%\.config\`.
- **WSL side**: home-manager's `xdg.configFile."x".source = ../../dotfiles/config/x;` symlinks it via the Nix store.

Both pointers reach the same file. To edit, change the dotfile and run `make restow` (and `nrs` for the Nix side).

## Terminal

### Zellij (daily driver)

GPU-free terminal multiplexer. Single pane by default; splits on demand via `Ctrl+P n/s/v`. Sessions persist across reboots. Catppuccin Mocha theme (matches rio/starship/Windows Terminal).

Run via `zj` (alias for `zellij attach --create`).

| Key | Action |
|---|---|
| `Ctrl+P` | Open command palette |
| `Ctrl+T` | New tab |
| `Ctrl+W` | Close tab/pane |
| `Ctrl+Q` | Quit zellij |
| `Ctrl+o d` | Detach session |
| `Ctrl+o w` | Session picker |

### Television (fuzzy finder)

TUI fuzzy finder (Rust). Press <kbd>Ctrl</kbd>+<kbd>F</kbd> in any shell to open `tv files`. Channels: `files`, `git-files`, `env`, `recent` (zoxide), `projects` (~/code). Custom channel files in `dotfiles/config/television/channels/`.

### Windows Terminal

Profiles: **NixOS (default), PowerShell 7, Command Prompt, Git Bash**.
Catppuccin Mocha color scheme, JetBrainsMono Nerd Font, acrylic 0.55.

Config: `dotfiles/config/windows-terminal/settings.json` (synced by stow into Windows Terminal's settings location; the installer only verifies the NixOS profile is present).

## Shell (fish)

fish is the default shell. Starship prompt, zoxide `cd`, direnv + nix-direnv, atuin + mcfly history, fzf keybindings.

### Prompt (starship — Catppuccin Mocha, rounded pills)

`❯ (wesley) ·(@Dev) ·(~/nix-config) ·git:( main) ·(go 1.23) ·(rust 1.83)`

Rounded parens `(…)`, soft `·` separator dots, each module in a distinct Catppuccin Mocha color. Time on the right edge.

### Key bindings

| Key | Action |
|---|---|
| `Ctrl+F` | Open television (fuzzy file finder) |
| `Ctrl+G` | Open navi (cheatsheet) |
| `Ctrl+R` | Reverse history search (fzf / atuin) |
| `Ctrl+T` | fzf file picker |
| `Up/Down` | History search (fish builtin) |

### Aliases (selection)

| Alias | Runs |
|---|---|
| `ll`, `l`, `lt`, `lta` | `eza` variants with icons + directories-first |
| `cat` → `bat --plain`; `catp` → `bat` |
| `grep` → `rg`; `find` → `fd`; `du` → `dust`; `df` → `duf`; `ps` → `procs`; `top` → `btop` |
| `vim`/`vi` → `nvim` |
| `g` → `git`; `lg` → `lazygit`; `ld` → `lazydocker` |
| `k` → `kubectl`; `kns` → `kubens`; `kctx` → `kubectx` |
| `d` → `docker`; `dc` → `docker compose` |
| `code`, `code-wsl` → VS Code (local + WSL) |
| `cc` → `claude`; `oc` → `opencode`; `gentle` → `gentle-ai`; `tv` → `television` |
| `zj` → `zellij attach --create` |
| `nrs` | `sudo nixos-rebuild switch` |
| `hms` | `home-manager switch --flake .` |
| `nfu` | `nix flake update` + `nrs` |
| `rm` → `trash-put` (recoverable) |

Full list: `home/wesley/fish.nix` (zsh/bash mirrors in `home/wesley/zsh.nix` and `home/wesley/bash.nix`).

### Functions

- `cd` → zoxide-backed (`z` with no args goes to most-frequent dir)
- `extract <file>` — untar/unzip/gunzip
- `mkcd <dir>` — mkdir + cd
- `v <file>` — nvim
- `g` (with subcommand) — git with nicer defaults
- `zj` — attach-or-create zellij session

### Cheatsheet (navi + tldr)

Press <kbd>Ctrl</kbd>+<kbd>G</kbd> in any interactive shell to open navi. Personal snippets in `dotfiles/config/navi/welcome.yaml` (nix-config rebuild, dotfiles sync, docker, k8s, git, system) + all `tldr` pages + shell history + fish aliases, fuzzy-searched. Type to filter, <kbd>Enter</kbd> to run.

For one-off lookups: `tldr <cmd>` (e.g. `tldr ffmpeg`, `tldr jq`).

## PowerShell 7 (Windows-side parity)

`dotfiles/home/powershell/Microsoft.PowerShell_profile.ps1` mirrors the fish aliases. Stowed into `~/Documents/PowerShell/`. Full feature set: PSReadLine predictive IntelliSense, starship, zoxide, fzf, eza, bat, ripgrep, fd, ripgrep, gsudo, lazygit, etc. Same `ll`, `cat`, `g`, `k`, `cc`, `oc`, `tv` aliases.

## Editor (Neovim via Nixvim)

Leader key is **space**. Hotkey help is `mini.clue` — pressing `<leader>` shows a small inline hint strip at the bottom with pending bindings (200ms delay, no full-screen popup). For on-demand lookup, `<leader>?` opens a Telescope keymap picker.

| Key | Action |
|---|---|
| `<space>ff` | Find files (Telescope) |
| `<space>fg` | Live grep |
| `<space>fb` | Buffers |
| `<space>fh` | Help tags |
| `<space>fr` | Recent files |
| `<space>fc` | Commands |
| `<space>fd` | Diagnostics |
| `<space>fs` / `<space>fS` | LSP document / workspace symbols |
| `<space>t` | Neo-tree file tree |
| `<space>rn` | LSP rename |
| `<space>ca` | LSP code action |
| `<space>?` | Search all keymaps (Telescope) |
| `gd` / `gD` / `gi` / `gr` | LSP definition / declaration / impl / refs |
| `K` | LSP hover |
| `<C-\>` | Toggle terminal |
| `<A-j>` / `<A-k>` | Move lines up/down (visual mode) |

LSP servers: `ts_ls`, `pyright`, `rust_analyzer`, `gopls`, `clangd`, `jdtls`, `lua_ls`, `gleam`, `dartls`, `phpactor`, `terraformls`, `yamlls`, `jsonls`, `html`, `cssls`, `tailwindcss`, `bashls`, `zls`, `denols`. Install via `:MasonInstall` (auto-installs on first trigger if configured).

## What this gives you

- **NixOS 26.05 (Yarara)** running inside WSL2 as the default distro, fully Nix-managed. Hostname: `Dev`.
- **`wesley`** is the default user. Passwordless `sudo` via `wheel`.
- **Home Manager** manages ~everything userland: shell, editor, terminal config, tools, dotfiles, git, gh, etc.
- **fish** default shell, with **starship** prompt, **zoxide** `cd`, **direnv** + **nix-direnv**, **atuin** + **mcfly** history, **fzf** keybindings.
- **Nixvim** primary editor (30+ plugins, full LSP for every language, mini.clue hotkey help).
- **Zellij** as the daily-driver terminal multiplexer. Sessions persist; restarts reattach.
- **television** TUI fuzzy finder (5 channels: files, git-files, env, recent, projects).
- **CLI stack**: `eza` `bat` `ripgrep` `fd` `jq` `yq` `fx` `sd` `choose` `dust` `duf` `procs` `btop` `yazi` `broot` `glow` `mosh` `trash-cli` `tldr` `navi` `pay-respects` `nix-ld` `lazygit` `lazydocker` `k9s` `dive` `opentofu` `pulumi` `claude-code` `opencode` `gentle-ai` `television`.
- **mise** owns language runtimes (node, bun, python/uv, luau, rust, go, etc.). The default tool set is in `dotfiles/config/mise/config.toml` (synced to `~/.config/mise/`); per-project versions go in `.tool-versions`. Rule of thumb: **language runtimes → mise, general CLI tools → Nix**.
- **Docker Desktop** on the Windows side provides the engine; the NixOS WSL distro talks to it over the named-pipe bridge.

## Common tasks

### Apply a change

```fish
# Inside WSL — stow + rebuild (the daily driver)
cd ~/nix-config/dotfiles && make restow
nrs

# Or from Windows PowerShell
irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/sync.ps1 | iex
```

### Update inputs

```fish
nfu           # alias: nix flake update + nixos-rebuild + home-manager
```

### Roll back

```fish
sudo nixos-rebuild --rollback switch
```

### WSL sudo setuid workaround (READ THIS)

The Nix store is on a separate ext4 partition that's remounted read-only during rebuilds. The setuid bit on `sudo` is lost after every rebuild. **After each rebuild, run as `root`**:

```bash
sudo chmod 4755 /nix/store/*-sudo-rs*/bin/sudo
```

As `wesley` this fails (the store path is owned by root and read-only after the rebuild remount). Run via `wsl -u root -- nix-config` or re-enter with `sudo -i` first.

### Add a new tool

Edit `home/wesley/cli-tools.nix` (or `terminal.nix` / `dev-tools.nix`) and add to `home.packages`:

```nix
home.packages = with pkgs; [
  # ... existing
  your-new-tool
];
```

Then `nrs`.

### Add a new system package

Edit `hosts/nixos-wsl/configuration.nix` and add to `environment.systemPackages`. For things that need to be available system-wide (currently kept minimal — vim, git, sudo, etc.).

### Add a new stow package

1. Create `dotfiles/<package>/` mirroring the target filesystem layout.
2. Add `<package>` to `PACKAGES` in `dotfiles/Makefile`.
3. Add the package to `stow --target=$HOME` invocations in `install/install.ps1` and `install/sync.ps1`.

### Add a new neovim plugin

Edit `home/wesley/nvim.nix` and add to `programs.nixvim.plugins.<name>`. If the plugin doesn't have a Nixvim module, add it to `extraPlugins` and write Lua config in `extraConfigLua`.

## WSL config

- `wsl.conf` is generated by the flake (read-only at runtime). `systemd=true`, `default=wesley`, `appendWindowsPath=false`, Windows drives mounted under `/mnt` with `metadata` flag.
- Docker socket: Docker Desktop's WSL integration is enabled manually (Docker Desktop → Settings → Resources → WSL Integration → enable NixOS).
- The repo lives at `C:\Users\parac\nix-config` on the Windows side and is symlinked from `~/nix-config` inside WSL via `ln -s /mnt/c/Users/parac/nix-config ~/nix-config`. Both sides see the same files; `realpath` resolves through the symlink so Nix can build transparently.

## Filesystem layout on disk

| Path | Lives in |
|---|---|
| `~/nix-config` | symlink → `C:\Users\parac\nix-config` (Windows NTFS) |
| `~/.config/starship.toml` | stow symlink → `~/nix-config/dotfiles/config/starship/starship.toml` |
| `~/.config/zellij/*` | stow symlink → `~/nix-config/dotfiles/config/zellij/*` |
| `~/.config/git/*` | stow symlink → `~/nix-config/dotfiles/config/git/*` |
| `~/.config/television/*` | stow symlink → `~/nix-config/dotfiles/config/television/*` |
| `~/.config/nvim` | generated by nixvim into `/nix/store/...` |
| `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | stow symlink → `~/nix-config/dotfiles/home/powershell/...` |
| Windows Terminal settings | `dotfiles/config/windows-terminal/settings.json` → stow syncs into `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\` |
| `%USERPROFILE%\.config\mise\config.toml` | stow symlink → `~/nix-config/dotfiles/config/mise/config.toml` |

## Useful references

- [omerxx/dotfiles](https://github.com/omerxx/dotfiles) — the stow pattern this repo is modeled after
- [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html)
- [NixOS manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager options](https://home-manager-options.extranix.com/)
- [Nixvim options](https://nixvim.pta2002.com/)
- [nixos-wsl docs](https://github.com/nix-community/nixos-wsl)
- [zellij docs](https://zellij.dev/documentation/)
- [television docs](https://github.com/alexpasmantier/television)
- [fish shell docs](https://fishshell.com/docs/current/)
- [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai)