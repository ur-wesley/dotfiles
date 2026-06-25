{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    envExtra = ''
      export EDITOR="nvim"
      export VISUAL="nvim"
      export PAGER="less"
      export MANPAGER="less"
      export TERMINAL="rio"
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"
      export PATH="$HOME/.local/bin:$PATH"
    '';
    shellAliases = {
      # Sane defaults
      ll = "eza -la --group-directories-first --icons";
      l = "eza -l --group-directories-first --icons";
      la = "eza -la --group-directories-first --icons";
      lt = "eza -T --level=2 --icons";
      lta = "eza -Ta --level=2 --icons";
      cat = "bat --paging=never";
      catp = "bat --plain";
      grep = "rg";
      find = "fd";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btop";
      vim = "nvim";
      vi = "nvim";
      g = "git";
      lg = "lazygit";
      ld = "lazydocker";
      k = "kubectl";
      kns = "kubens";
      kctx = "kubectx";
      d = "docker";
      dc = "docker compose";
      j = "just";

      # Quick navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "~" = "cd ~";

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

    initContent = /* shell */ ''
      # ---- Environment ----
      export EDITOR="nvim"
      export VISUAL="nvim"
      export PAGER="less"
      export MANPAGER="less"
      export TERMINAL="rio"
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"
      export PATH="$HOME/.local/bin:$PATH"

      # ---- zsh options ----
      setopt AUTO_CD
      setopt INTERACTIVE_COMMENTS
      setopt NO_CASE_GLOB
      setopt NUMERIC_GLOB_SORT
      setopt PROMPT_SUBST
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_FIND_NO_DUPS
      setopt HIST_SAVE_NO_DUPS

      HISTFILE="$HOME/.zsh_history"
      HISTSIZE=100000
      SAVEHIST=100000

      # ---- Key bindings ----
      bindkey -e
      bindkey '^p' history-substring-search-up
      bindkey '^n' history-substring-search-down
      bindkey '^r' history-incremental-search-backward

      # ---- fzf shell integration (provided by home-manager) ----
      source ~/.fzf.zsh 2>/dev/null || true

      # ---- Completions ----
      autoload -Uz compinit && compinit -d "$HOME/.cache/zsh/compdump"
      zstyle ":completion:*" menu select
      zstyle ":completion:*" group-name ""
      zstyle ":completion:*:descriptions" format "%F{cyan}-- %d --%f"

      # ---- fzf extras ----
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --preview='bat --color=always --style=numbers --line-range=:500 {}' --preview-window='right:50%:wrap'"
      export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache --exclude .npm --exclude .next --exclude dist"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .cache"

      # ---- mise (runtimes) ----
      if [ -d "$HOME/.local/share/mise" ]; then
        export PATH="$HOME/.local/share/mise/bin:$PATH"
        eval "$(mise activate zsh 2>/dev/null)" 2>/dev/null || true
      fi
      # Fallback: native Linux paths for mise on WSL
      [ -d "$HOME/.local/bin/mise" ] && export PATH="$HOME/.local/bin/mise:$PATH"

      # ---- ssh agent (systemd) ----
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

      # ---- less: better ----
      export LESS="-R --no-init --quit-if-one-screen --quit-on-intr"

      # ---- bat theme ----
      export BAT_THEME="Catppuccin Mocha"

      # ---- delta (git pager) ----
      export DELTA_FEATURES="+side-by-side"
    '';

    # Use oh-my-zsh-style plugins via zsh-autosuggestions + syntax-highlighting
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
    ];
  };
}
