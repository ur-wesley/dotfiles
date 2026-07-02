{ config, pkgs, lib, ... }:

{
  # Minimal bash config — kept around so #!/usr/bin/env bash
  # shebang scripts inside Nix store paths still work, and any
  # tools that shell out to bash (e.g. some Makefile recipes)
  # have something sane to land in.
  programs.bash = {
    enable = true;
    # Match fish/zsh — no login banner, sane defaults
    bashrcExtra = ''
      export EDITOR="nvim"
      export VISUAL="nvim"
      export PAGER="less"
      export MANPAGER="less"
      export TERMINAL="rio"
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"

      # History shared across sessions
      export HISTSIZE=100000
      export HISTFILESIZE=100000
      export HISTCONTROL=ignoreboth:erasedups
      shopt -s histappend

      # fzf shell integration (provided by home-manager)
      [ -f ~/.fzf.bash ] && source ~/.fzf.bash

      # mise (runtimes) on both Linux and Windows
      if [ -d "$HOME/.local/share/mise" ]; then
        export PATH="$HOME/.local/share/mise/bin:$PATH"
        eval "$(mise activate bash 2>/dev/null)" 2>/dev/null || true
      fi
      if [ -d "$HOME/.local/bin/mise" ]; then
        export PATH="$HOME/.local/bin/mise:$PATH"
      fi
    '';
    # Minimal aliases — keep them in sync with fish.nix / zsh.nix
    shellAliases = {
      ll = "eza -la --group-directories-first --icons";
      l = "eza -l --group-directories-first --icons";
      lt = "eza -T --level=2 --icons";
      lta = "eza -Ta --level=2 --icons";
      cat = "bat --style=plain --paging=never";
      catp = "bat --plain";
      grep = "rg";
      find = "fd";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btop";
      vim = "nvim";
      vi = "nvim";
      helix = "hx";
      g = "git";
      lg = "lazygit";
      ld = "lazydocker";
      k = "kubectl";
      kns = "kubens";
      kctx = "kubectx";
      d = "docker";
      dc = "docker compose";
      j = "just";
      code = "code";
      cc = "claude";
      oc = "opencode";
      rm = "trash-put";
      cp = "cp -i";
      mv = "mv -i";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      nrs = "doas nixos-rebuild switch --flake ~/nix-config#nixos-wsl";
      nrt = "doas nixos-rebuild test --flake ~/nix-config#nixos-wsl";
      nrb = "doas nixos-rebuild boot --flake ~/nix-config#nixos-wsl";
      hms = "home-manager switch --flake ~/nix-config#wesley@nixos-wsl";
      nfu = "nix flake update ~/nix-config && doas nixos-rebuild switch --flake ~/nix-config#nixos-wsl && home-manager switch --flake ~/nix-config#wesley@nixos-wsl";
      ncl = "nix-collect-garbage -d";
    };
  };
}