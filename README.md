# nix-config

Wesley's NixOS-WSL flake. Single source of truth for the entire dev
environment on this Windows box.

## Quick start

### On a fresh Windows machine

```powershell
# Right-click PowerShell, "Run as Administrator"
irm https://raw.githubusercontent.com/ur-wesley/dotfiles/main/install/install.ps1 -Repo ur-wesley/dotfiles | iex
```

This installs winget packages, NixOS-WSL, WezTerm, fonts, and clones this
repo. After the script finishes:

1. Open **WezTerm** — it drops you into fish inside NixOS-WSL
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

### WezTerm leader key (C-a)

| Key | Action |
|---|---|
| `C-a \|` | Split horizontal |
| `C-a -` | Split vertical |
| `C-a h/j/k/l` | Navigate panes |
| `C-a H/J/K/L` | Resize panes |
| `C-a z` | Zoom/unzoom pane |
| `C-a x` | Close pane |
| `C-a t` | New tab |
| `C-a n/p` | Next/prev tab |
| `C-a c` | Close tab |
| `C-a r` | Rename tab |
| `C-a 1/2/3` | Switch workspace (Dev / Dev2 / Win) |
| `C-a r` (SHIFT) | Reload config |
| `C-a p` (SHIFT) | Command palette |
| `C-a /` | Search |
| `C-a f` | Copy mode |

## What this gives you

- **NixOS 26.05 (Yarara)** running inside WSL2 as the default distro,
  fully Nix-managed. Hostname: `Dev`.
- **`wesley`** is the default user. Passwordless `sudo` via `wheel`.
- **Home Manager** manages ~everything userland: shell, editor, tools,
  dotfiles, git, gh, etc.
- **fish** is the default shell (with zsh + bash still available).
- **Nixvim** as the primary editor (30+ plugins, full LSP for every
  language you use).
- **WezTerm as the multiplexer** — splits, panes, tabs, workspaces,
  copy mode, all in one app. tmux/zellij are kept as binaries only
  (no autostart) as a fallback.
- **Opinionated terminal stack**: `fish` + `starship` + `lazygit`
  + `lazydocker` + `k9s` + `dive` + `yazi` + `btop` + `fzf` + `zoxide`
  + `atuin` + `mcfly` + `direnv` + `nix-direnv` + `gh` + `delta`.
- **Mise** on the Linux side still owns language runtimes (node, go,
  bun, rust, dotnet, python, luau, uv) so per-project pinning keeps
  working unchanged.
- **Docker Desktop** on the Windows side provides the engine; the
  NixOS WSL distro talks to it over the named-pipe bridge.
- **Portable installer** — run `install/install.ps1` on a fresh Windows
  box and it bootstraps the same environment end-to-end.

## Layout

```
nix-config/
├── flake.nix                  # inputs + outputs
├── flake.lock                 # auto-generated
├── install/
│   ├── install.ps1            # one-shot Windows installer (winget + WSL + repo sync)
│   ├── install.bat            # .bat wrapper for double-click install
│   └── sync.ps1               # pull latest config + apply on this PC
├── dotfiles/
│   ├── wezterm/wezterm.lua    # Windows-side WezTerm config
│   └── windows-terminal/settings.json   # Windows Terminal profiles
├── hosts/nixos-wsl/
│   └── configuration.nix      # NixOS system config (WSL)
└── home/wesley/
    ├── core.nix               # starship, fzf, zoxide, direnv, nix-direnv
    ├── fish.nix               # fish shell + aliases + functions + abbrs
    ├── git.nix                # git + delta + gh config
    ├── terminal.nix           # TUI tools (tmux/zellij binaries as fallback)
    ├── cli-tools.nix          # eza, bat, ripgrep, fd, jq, yq, btop, yazi
    ├── dev-tools.nix          # docker, k8s, cloud CLIs, build tools
    └── nvim.nix               # Nixvim (full editor config)
```

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
# NixOS keeps generations
sudo nixos-rebuild --rollback switch
```

### WSL sudo setuid workaround (READ THIS)

The nix store is on a separate ext4 partition that's remounted read-only
during rebuilds. The setuid bit on `sudo` is lost after every rebuild.
**After each rebuild, run:**

```bash
sudo chmod 4755 /nix/store/*-sudo-rs*/bin/sudo
```

(You can do this as `wesley` since sudo itself still has setuid from
the previous fix.)

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
`environment.systemPackages`. This is for things that need to be
available system-wide (currently kept minimal — vim, git, sudo, etc.).

### Add a new neovim plugin

Edit `home/wesley/nvim.nix` and add to `programs.nixvim.plugins.<name>`.
If the plugin doesn't have a Nixvim module, add it to `extraPlugins`
and write Lua config in `extraConfigLua`.

## Default user + shell

`wesley` with **fish** as the default shell. Configured in
`hosts/nixos-wsl/configuration.nix` under `users.users.wesley.shell = pkgs.fish`
and `wsl.defaultUser = "wesley"`.

zsh and bash remain available — use `chsh` or pass the shell as an
argument to switch.

## Shell (fish)

fish is the default. It does autosuggestions, syntax highlighting, and
tab completions out of the box. The `home/wesley/fish.nix` module
adds: starship prompt, fzf keybindings, zoxide integration, mise
activation, and ~30 aliases.

Useful aliases (full list in `home/wesley/fish.nix`):

- `ll`, `la`, `lt`, `lta` — `eza` variants
- `cat` → `bat`; `grep` → `rg`; `find` → `fd`; `du` → `dust`; `df` → `duf`; `ps` → `procs`; `top` → `btop`
- `vim`/`vi` → `nvim`
- `g` → `git`; `lg` → `lazygit`; `ld` → `lazydocker`
- `k` → `kubectl`; `kns` → `kubens`; `kctx` → `kubectx`
- `nrs` → rebuild NixOS; `hms` → rebuild home-manager
- `nfu` → update flake + rebuild both
- `rm` → `trash-put` (recoverable delete)

Useful functions:

- `extract <file>` — untar/unzip/gunzip
- `mkcd <dir>` — mkdir + cd
- `v <file>` — nvim

Abbreviations (auto-expanded when you type them as commands):

- `gco` → `git checkout`
- `gst` → `git status`
- `gp`  → `git push`
- `gl`  → `git pull --rebase`
- `gc`  → `git commit`
- `ga`  → `git add`
- `gd`  → `git diff`
- `gb`  → `git branch`
- `glg` → `git log --oneline --graph --decorate -20`

## Editor (Neovim via Nixvim)

Leader key is **space**. Important bindings:

- `<space>ff` — find files (Telescope)
- `<space>fg` — live grep
- `<space>fb` — buffers
- `<space>e`  — diagnostic float
- `<space>t`  — Neo-tree file tree
- `<space>r`  — Telescope
- `gd`/`gD`/`gi`/`gr` — LSP go to definition/declaration/impl/refs
- `K`         — LSP hover
- `<space>rn` — LSP rename
- `<space>ca` — LSP code action
- `<C-\>`     — toggle terminal
- `<A-j>`/`<A-k>` — move lines up/down in visual mode

LSP servers are pre-defined; install them via `:MasonInstall`
(or they auto-install on first trigger if `mason-lspconfig` is configured
to auto-install).

## WSL config

- `wsl.conf` is generated by the flake (read-only at runtime).
  `systemd=true`, `default=wesley`, `appendWindowsPath=false`,
  Windows drives mounted under `/mnt` with `metadata` flag.
- Docker socket: Docker Desktop's WSL integration is enabled
  manually (Docker Desktop → Settings → Resources → WSL
  Integration → enable NixOS).
- WezTerm is configured on the Windows side to default to
  `wsl.exe -d NixOS -- fish -l` (see `~/.config/wezterm/wezterm.lua`).

## What this flake does NOT touch (yet)

Per your "skip for now" call, the following are deferred:

- VS Code extensions (currently 77 installed — candidates for pruning)
- AI tool dotfolders (`.claude`, `.cursor`, `.codex`, `.gemini`, `.qwen`, `.junie`, `.copilot`, `.antigravity`, `.ghcp-appmod`)
- Native Windows toolchains (Python 3.11, Java 8, .NET 9, PHP 8.4, PostgreSQL 18 on Windows — can be moved into NixOS)
- ~~Arch WSL distro~~ — done; `wsl --unregister archlinux`
- ~~Podman machine~~ — done; `wsl --unregister podman-machine-default`

When you're ready, see the "Cleanup TODO" at the bottom.

## Useful references

- [NixOS manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager options search](https://home-manager-options.extranix.com/)
- [Nixvim options](https://nixvim.pta2002.com/)
- [nixos-wsl docs](https://github.com/nix-community/nixos-wsl)
- [fish shell docs](https://fishshell.com/docs/current/)

## Cleanup TODO

When ready, address:

- [ ] Prune VS Code to ~12 essentials (run from PowerShell):
      `code --list-extensions | ForEach-Object { code --uninstall-extension $_ }`
      then install only what you actually use.
- [ ] Pick 1-2 AI coding CLIs from `.claude`, `.codex`, `.gemini`, `.qwen`, `.junie`, `.copilot`, `.antigravity`, `.ghcp-appmod`, `.ghcp-appmod-java`, `.glzr` and delete the others.
- [ ] Uninstall native Windows Python, Java, .NET, PHP, PostgreSQL — use the NixOS versions instead.
- [x] ~~Remove `archlinux` WSL distro~~ — done; `wsl --unregister archlinux`
- [x] ~~Remove `podman-machine-default`~~ — done; `wsl --unregister podman-machine-default`
- [ ] Move projects from `C:\Users\parac\Projects` to `~/code/` inside NixOS for filesystem perf.
- [ ] Wire VS Code to use the NixOS LSP servers via `Remote - SSH` to `localhost` (NixOS WSL).
- [ ] Remove the `sudo chmod 4755` workaround by switching to a WSL-friendly sudo (e.g. add it to a sudo-wrapped nix store path or use `nixos-rebuild` via `wsl -u root`).
