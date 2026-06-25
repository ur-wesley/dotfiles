# nix-config

Wesley's NixOS-WSL flake. Single source of truth for the entire dev
environment on this Windows box — shell, editor, terminal, dev tools,
and dotfiles.

The repo lives at `C:\Users\parac\nix-config` on the Windows side and
is symlinked from `~/nix-config` inside WSL so both sides see the
same files.

## Quick start

### On a fresh Windows machine

```powershell
# Right-click PowerShell, "Run as Administrator"
irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/install.ps1 -Repo ur-wesley/dotfiles | iex
```

This installs winget packages, NixOS-WSL, fonts, and clones this
repo. After the script finishes:

1. Open **Rio** (or Windows Terminal on the NixOS profile) — drops you into fish inside NixOS-WSL
2. Inside the WSL shell:
   ```fish
   sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl
   ```
3. Done. Same prompt, same tools, same everything.

### Sync latest config onto an existing machine

```powershell
# From PowerShell (any user, no admin needed)
irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/sync.ps1 | iex
```

Or just:
```fish
# Inside WSL
cd ~/nix-config
git pull
nrs   # alias: nixos-rebuild switch
```

## Layout

```
nix-config/
├── flake.nix                       # inputs + outputs
├── flake.lock                      # auto-generated
├── README.md                       # you are here
├── .gitattributes                  # line-ending policy (LF)
├── install/
│   ├── install.ps1                 # one-shot Windows installer (winget + WSL + repo)
│   ├── install.bat                 # .bat wrapper for double-click
│   └── sync.ps1                    # pull latest config + apply on this PC
├── dotfiles/                       # synced to Windows locations by sync.ps1
│   ├── rio/config.toml             # Rio terminal config (Windows-side)
│   ├── mise/config.toml            # mise runtime manager config
│   └── windows-terminal/settings.json   # Windows Terminal profiles
├── hosts/nixos-wsl/
│   └── configuration.nix           # NixOS system config (WSL)
└── home/wesley/
    ├── home.nix                    # user account, stateVersion
    ├── core.nix                    # starship, fzf, zoxide, direnv, nix-direnv, atuin, mcfly
    ├── fish.nix                    # fish shell + aliases + functions + abbrs
    ├── git.nix                     # git + delta + gh + lazygit + git-cliff
    ├── terminal.nix                # TUI tools (tmux/zellij binaries as fallback)
    ├── cli-tools.nix               # eza, bat, ripgrep, fd, jq, yq, btop, yazi, opencode, claude-code
    ├── dev-tools.nix               # docker, k8s, cloud CLIs, build tools
    ├── zsh.nix                     # zsh fallback shell
    └── nvim.nix                    # Nixvim (full editor config)
```

## Terminal

Two terminals are configured. Pick whichever feels right:

### Rio (daily driver)

GPU-accelerated, minimal, dark by default with Catppuccin Mocha.
Tab bar auto-hides when only one tab is open (`hide-if-single`).
Hint mode (`Ctrl+Shift+O`) overlays labels on URLs so you can hit
a letter to copy them. Glass/blur background, JetBrainsMono Nerd Font.

Config: `dotfiles/rio/config.toml` (synced to
`%USERPROFILE%\AppData\Local\rio\config.toml` by sync.ps1).

### Rio defaults (Ctrl+Shift+...)

| Key | Action |
|---|---|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+N` | New window |
| `Ctrl+Shift+R` | Reload config |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+F` | Search |
| `Ctrl+Shift+O` | Hint mode (URLs, etc.) |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / prev tab |
| `Ctrl+Shift+1..8` | Switch to tab N |

## Shell (fish)

fish is the default shell (`chsh` to swap; zsh/bash still available).
Built-in autosuggestions, syntax highlighting, and tab completions.

### Prompt (starship — Catppuccin Mocha, rounded pills)

`❯ (wesley) ·(@Dev) ·(~/nix-config) ·git:( main) ·(go 1.23) ·(rust 1.83)`

Rounded parens `(…)`, soft `·` separator dots between modules,
each module in a distinct Catppuccin Mocha color. Time on the right
edge.

### Aliases (selection)

| Alias | Runs |
|---|---|
| `ll`, `la`, `l`, `lt`, `lta` | `eza` variants with icons + directories-first |
| `cat` → `bat`; `grep` → `rg`; `find` → `fd`; `du` → `dust`; `df` → `duf`; `ps` → `procs`; `top` → `btop`; `catp` → `bat --plain` |
| `vim`/`vi` → `nvim` |
| `g` → `git`; `lg` → `lazygit`; `ld` → `lazydocker` |
| `k` → `kubectl`; `kns` → `kubens`; `kctx` → `kubectx` |
| `nrs` | `sudo nixos-rebuild switch` |
| `hms` | `home-manager switch --flake .` |
| `nfu` | `nix flake update` + `nrs` |
| `rm` → `trash-put` (recoverable) |

Full list: `home/wesley/fish.nix`.

### Abbreviations (auto-expanded in command position)

`gco` `gst` `gp` `gl` `gc` `ga` `gd` `gb` `glg` → `git checkout`
/ `status` / `push` / `pull --rebase` / `commit` / `add` / `diff`
/ `branch` / `log --oneline --graph --decorate -20`.

### Functions

- `cd` → zoxide-backed (`z` with no args goes to the most-frequent dir)
- `extract <file>` — untar/unzip/gunzip
- `mkcd <dir>` — mkdir + cd
- `v <file>` — nvim
- `g` (with subcommand) — git with nicer defaults

## Editor (Neovim via Nixvim)

Leader key is **space**. Hotkey help is `mini.clue` — pressing
`<leader>` shows a small inline hint strip at the bottom with
pending bindings (200ms delay, no full-screen popup). For on-demand
lookup, `<leader>?` opens a Telescope keymap picker.

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
| `<space>e` | Diagnostic float |
| `<space>t` | Neo-tree file tree |
| `<space>rn` | LSP rename |
| `<space>ca` | LSP code action |
| `<space>?` | Search all keymaps (Telescope) |
| `gd` / `gD` / `gi` / `gr` | LSP definition / declaration / impl / refs |
| `K` | LSP hover |
| `<C-\>` | Toggle terminal |
| `<A-j>` / `<A-k>` | Move lines up/down (visual mode) |
| `<C-d>` / `<C-u>` | Half-page scroll + center |
| `<C-j>` / `<C-k>` | Next / prev diagnostic |

LSP servers: `ts_ls`, `pyright`, `rust_analyzer`, `gopls`, `clangd`,
`jdtls`, `lua_ls`, `gleam`, `dartls`, `phpactor`, `terraformls`,
`yamlls`, `jsonls`, `html`, `cssls`, `tailwindcss`, `bashls`,
`zls`, `denols`. Install via `:MasonInstall` (auto-installs on first
trigger if configured).

## What this gives you

- **NixOS 26.05 (Yarara)** running inside WSL2 as the default distro,
  fully Nix-managed. Hostname: `Dev`.
- **`wesley`** is the default user. Passwordless `sudo` via `wheel`.
- **Home Manager** manages ~everything userland: shell, editor,
  terminal config, tools, dotfiles, git, gh, etc.
- **fish** default shell, with **starship** prompt, **zoxide** `cd`,
  **direnv** + **nix-direnv**, **atuin** + **mcfly** history,
  **fzf** keybindings.
- **Nixvim** primary editor (30+ plugins, full LSP for every
  language you use, mini.clue for hotkey help, mini.clue `<leader>?`
  for on-demand lookup).
- **Rio** as the daily-driver terminal. tmux/zellij are kept as
  binaries only (no autostart) as a fallback for raw SSH sessions.
  Both spawn fish in NixOS-WSL. tmux/zellij are kept as binaries only
  (no autostart).
- **CLI stack**: `eza` `bat` `ripgrep` `fd` `jq` `yq` `fx` `sd` `choose`
  `dust` `duf` `procs` `btop` `yazi` `broot` `glow` `mosh` `trash-cli`
  `tldr` `pay-respects` `nix-ld` `lazygit` `lazydocker` `k9s` `dive`
  `kubectx` `stern` `helm` `kustomize` `opentofu` `pulumi` `awscli2`
  `azure-cli` `gcloud` `opencode` `claude-code`.
- **mise** owns language runtimes (node, bun, python/uv, luau,
  rust, go, etc.). The default tool set is in
  `dotfiles/mise/config.toml` (synced to `~/.config/mise/`); per-project
  versions go in `.tool-versions`. Rule of thumb: **language runtimes
  → mise, general CLI tools → Nix**.
- **Docker Desktop** on the Windows side provides the engine; the
  NixOS WSL distro talks to it over the named-pipe bridge.

## Common tasks

### Apply a change

```bash
# NixOS system + home-manager together
sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl

# Or the alias (defined in fish)
nrs
```

### Update inputs

```bash
nfu           # alias: nix flake update + nixos-rebuild + home-manager
```

### Roll back

```bash
sudo nixos-rebuild --rollback switch
```

### WSL sudo setuid workaround (READ THIS)

The Nix store is on a separate ext4 partition that's remounted
read-only during rebuilds. The setuid bit on `sudo` is lost after
every rebuild. **After each rebuild, run as `root`**:

```bash
sudo chmod 4755 /nix/store/*-sudo-rs*/bin/sudo
```

As `wesley` this fails (the store path is owned by root and read-only
after the rebuild remount). Run via `wsl -u root -- nix-config` or
re-enter with `sudo -i` first.

### Add a new tool

Edit the right file in `home/wesley/` and add to `home.packages`:

```nix
home.packages = with pkgs; [
  # ... existing
  your-new-tool
];
```

Then `nrs` (or `sudo nixos-rebuild switch`).

### Add a new system package

Edit `hosts/nixos-wsl/configuration.nix` and add to
`environment.systemPackages`. For things that need to be available
system-wide (currently kept minimal — vim, git, sudo, etc.).

### Add a new neovim plugin

Edit `home/wesley/nvim.nix` and add to `programs.nixvim.plugins.<name>`.
If the plugin doesn't have a Nixvim module, add it to `extraPlugins`
and write Lua config in `extraConfigLua`.

## WSL config

- `wsl.conf` is generated by the flake (read-only at runtime).
  `systemd=true`, `default=wesley`, `appendWindowsPath=false`,
  Windows drives mounted under `/mnt` with `metadata` flag.
- Docker socket: Docker Desktop's WSL integration is enabled
  manually (Docker Desktop → Settings → Resources → WSL
  Integration → enable NixOS).
- The repo lives at `C:\Users\parac\nix-config` on the Windows side
  and is symlinked from `~/nix-config` inside WSL via
  `ln -s /mnt/c/Users/parac/nix-config ~/nix-config`. Both sides
  see the same files; `realpath` resolves through the symlink so
  Nix can build transparently.

## Filesystem layout on disk

| Path | Lives in |
|---|---|
| `~/nix-config` | symlink → `C:\Users\parac\nix-config` (Windows NTFS) |
| `~/.config/starship.toml` | symlink → `/nix/store/...home-manager-files/.config/starship.toml` |
| `~/.config/nvim` | generated by nixvim into `/nix/store/...` |
| Windows Terminal settings | `dotfiles/windows-terminal/settings.json` → synced by `sync.ps1` |
| Rio config | `dotfiles/rio/config.toml` → synced by `sync.ps1` to `%USERPROFILE%\AppData\Local\rio\config.toml` |

## Useful references

- [NixOS manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager options](https://home-manager-options.extranix.com/)
- [Nixvim options](https://nixvim.pta2002.com/)
- [nixos-wsl docs](https://github.com/nix-community/nixos-wsl)
- [fish shell docs](https://fishshell.com/docs/current/)
- [Rio terminal docs](https://rioterm.com/docs/config)

## Cleanup TODO

Done:

- [x] ~~Remove `archlinux` WSL distro~~ — done; `wsl --unregister archlinux`
- [x] ~~Remove `podman-machine-default`~~ — done; `wsl --unregister podman-machine-default`
- [x] ~~Move dotfiles repo to Windows + symlink~~ — done; `~/nix-config` → `C:\Users\parac\nix-config`
- [x] ~~Replace which-key with mini.clue in nvim~~ — done

Still to do:

- [ ] Prune VS Code to ~12 essentials:
      `code --list-extensions | ForEach-Object { code --uninstall-extension $_ }`
      then install only what you actually use.
- [ ] Pick 1-2 AI coding CLIs from `.claude`, `.codex`, `.gemini`,
      `.qwen`, `.junie`, `.copilot`, `.antigravity`, `.ghcp-appmod`
      and delete the others. Current default: opencode + claude-code.
- [ ] Uninstall native Windows Python, Java, .NET, PHP, PostgreSQL —
      use the NixOS versions instead.
- [ ] Move projects from `C:\Users\parac\Projects` to `~/code/`
      inside NixOS for filesystem perf.
- [ ] Wire VS Code to use the NixOS LSP servers via
      `Remote - SSH` to `localhost` (NixOS WSL).
- [ ] Bump opencode to the latest upstream release
      (currently pinned to nixpkgs's 1.17.7; latest is 1.17.10).
- [ ] Remove the `sudo chmod 4755` workaround by switching to a
      WSL-friendly sudo (e.g. add it to a sudo-wrapped nix store
      path or use `nixos-rebuild` via `wsl -u root`).