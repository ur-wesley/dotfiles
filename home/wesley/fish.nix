{ config, pkgs, lib, ... }:

{
  # fish shell configuration
  programs.fish = {
    enable = true;
    package = pkgs.fish;

    # Default shell prompt
    shellInit = ''
      # ---- Environment (set in all shells) ----
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx PAGER less
      set -gx MANPAGER less
      set -gx TERMINAL rio
      set -gx LANG en_US.UTF-8
      set -gx LC_ALL en_US.UTF-8

      # ---- XDG paths ----
      set -gx XDG_CONFIG_HOME $HOME/.config
      set -gx XDG_DATA_HOME $HOME/.local/share
      set -gx XDG_STATE_HOME $HOME/.local/state
      set -gx XDG_CACHE_HOME $HOME/.cache
    '';

    interactiveShellInit = ''
      # ---- Path additions (interactive only — fish_add_path persists) ----
      fish_add_path -p $HOME/.local/bin
      fish_add_path -p $HOME/.local/share/mise/bin

      # ---- mise (runtimes) ----
      if test -d "$HOME/.local/share/mise"
        mise activate fish | source
      end

      # ---- ssh agent (systemd) ----
      set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

      # ---- bat theme ----
      set -gx BAT_THEME "Catppuccin Mocha"

      # ---- delta (git pager) ----
      set -gx DELTA_FEATURES "+side-by-side"

      # ---- less ----
      set -gx LESS "-R --no-init --quit-if-one-screen --quit-on-intr"

      # ---- history ----
      set -U fish_history_size 100000

      # ---- mcfly: use fish history file ----
      if test -z "$MCFLY_HISTFILE"
        set -gx MCFLY_HISTFILE $XDG_DATA_HOME/mcfly/fish_history
      end

      # ---- zoxide: replace `cd` with zoxide ----
      # `z foo` jumps to the most frecent match; `cd` keeps the
      # plain semantics (no jump) and just falls through to the
      # builtin. We override `cd` to be the zoxide one so the
      # smart-jump behavior is transparent.
      function cd
        if test (count $argv) -eq 0
          z ~
        else
          z $argv
        end
      end
    '';

    # Interactive key bindings — bound here (outside the
    # `status is-interactive` block) so they take effect in every
    # interactive shell, including subshells.
    binds = {
      # navi: open the interactive cheatsheet (your snippets +
      # tldr + fish aliases + shell history, fuzzy-searched). The
      # default <C-g> binding is what navi's docs recommend.
      ctrl-g = { command = "navi --print"; };

      # television: fuzzy find files in current directory.
      # Channel switching: Alt+1..Alt+5 for files/git-files/env/recent/projects.
      ctrl-f = { command = "tv files"; };
    };

    # Aliases
    shellAliases = {
      # Sane defaults — eza with icons + directories-first
      ll = "eza -la --group-directories-first --icons";
      l = "eza -l --group-directories-first --icons";
      lt = "eza -T --level=2 --icons";
      lta = "eza -Ta --level=2 --icons";

      # cat → bat. Plain mode is pipe-safe (no decorations, no
      # paging) so things like `cat file.json | jq` still work.
      cat = "bat --style=plain --paging=never";
      catp = "bat --plain";

      # Modern replacements
      grep = "rg";
      find = "fd";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btop";
      ping = "gping";
      serve = "python3 -m http.server";
      json = "jq";
      xml = "xmllint --format -";

      # Editor
      vim = "nvim";
      vi = "nvim";
      helix = "hx";

      # Git (single-letter shortcuts)
      g = "git";
      lg = "lazygit";
      ld = "lazydocker";

      # K8s
      k = "kubectl";
      kns = "kubens";
      kctx = "kubectx";

      # Docker
      d = "docker";
      dc = "docker compose";

      # Misc
      j = "just";

      # VS Code
      code = "code";
      code-wsl = "code --remote wsl+NixOS";

      # Quick navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # AI coding CLIs
      cc = "claude";
      oc = "opencode";
      gentle = "gentle-ai";
      tv = "television";
      zj = "zellij attach --create";

      # Cheatsheets
      cheat = "navi";

      # Safety
      rm = "trash-put";
      cp = "cp -i";
      mv = "mv -i";

      # Nix
      nrs = "sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl";
      nrt = "sudo nixos-rebuild test --flake ~/nix-config#nixos-wsl";
      nrb = "sudo nixos-rebuild boot --flake ~/nix-config#nixos-wsl";
      nrf = "sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl --refresh";
      hms = "home-manager switch --flake ~/nix-config#wesley@nixos-wsl";
      nfu = "nix flake update ~/nix-config && sudo nixos-rebuild switch --flake ~/nix-config#nixos-wsl && home-manager switch --flake ~/nix-config#wesley@nixos-wsl";
      ncl = "nix-collect-garbage -d";
    };

    # Functions (fish functions)
    functions = {
      # Extract common archive types. The fallback case is
      # written with `printf` + fish string concat so filenames
      # with spaces or quotes work.
      extract = "switch $argv[1]
        case '*.tar.bz2'
          tar xjf $argv[1]
        case '*.tar.gz'
          tar xzf $argv[1]
        case '*.bz2'
          bunzip2 $argv[1]
        case '*.rar'
          unrar x $argv[1]
        case '*.gz'
          gunzip $argv[1]
        case '*.tar'
          tar xf $argv[1]
        case '*.tbz2'
          tar xjf $argv[1]
        case '*.tgz'
          tar xzf $argv[1]
        case '*.zip'
          unzip $argv[1]
        case '*.Z'
          uncompress $argv[1]
        case '*.7z'
          7z x $argv[1]
        case '*'
          printf '\"%s\" cannot be extracted via extract()\\n' $argv[1]
      end";

      # Create directory and cd into it
      mkcd = "mkdir -p $argv[1]; and cd $argv[1]";

      # Open in nvim
      v = "nvim $argv";

      # Git helpers (functions shadow the abbreviations of the same
      # name, so the abbreviation block below omits them)
      gst = "git status -sb";
      gco = "git checkout";
      gcb = "git checkout -b";
      gcm = "git commit -m";
      gp = "git push";
      gl = "git pull --rebase --autostash";
    };

    # History (set via universal vars in interactiveShellInit)

    # Completions (use default; custom completions go in this attr)
    # completions = { };

    # Abbreviations (auto-expanded in command position).
    # Note: gco / gp / gl are NOT here — they're defined as fish
    # functions above with extra flags (gco can take a branch arg
    # without losing it, gp/gl have --rebase/--autostash). Functions
    # win over abbreviations in fish, so duplicating here would
    # silently override the function bodies.
    shellAbbrs = {
      gst = "git status";
      gc = "git commit";
      ga = "git add";
      gd = "git diff";
      gds = "git diff --staged";
      gb = "git branch";
      glg = "git log --oneline --graph --decorate -20";
    };

    # Set fish as login shell? No - WSL sets login shell.
    # loginShellInit for login shell specific stuff
    loginShellInit = ''
      # Ensure PATH is set up properly for SSH sessions
      fish_add_path -p /run/current-system/sw/bin

      # WSL workaround: nix store is on a separate ext4 partition
      # that loses the setuid bit on every rebuild. Fix it on login.
      for sudo_path in /nix/store/*-sudo*/bin/sudo /nix/store/*-sudo-rs*/bin/sudo
        if test -f "$sudo_path"; and not test -u "$sudo_path"
          sudo -n true 2>/dev/null; or command sudo -n chmod 4755 "$sudo_path" 2>/dev/null
        end
      end
    '';
  };
}
