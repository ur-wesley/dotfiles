{ config, pkgs, lib, ... }:

{
  # Git + delta + gh + git-cliff + pre-commit
  home.packages = with pkgs; [
    git
    gh
    glab
    lazygit
    git-cliff
    pre-commit
    commitlint
  ];

  # Source the shared git config from dotfiles/config/git/config so home-manager
  # (WSL) and stow (Windows) share one file. Home-manager creates
  # ~/.config/git/config as a symlink to a Nix store copy of the file.
  # Identity lives in the shared file (no per-host override for now).
  xdg.configFile."git/config".source = ../../dotfiles/config/git/config;

  # Global gitignore sourced from dotfiles/config/git/ignore.
  home.file.".config/git/ignore".source = ../../dotfiles/config/git/ignore;

  # gitattributes sourced from dotfiles/config/git/attributes.
  home.file.".config/git/attributes".source = ../../dotfiles/config/git/attributes;

  # We do NOT use programs.git here — settings come entirely from the
  # shared config file. Home-manager would otherwise generate a parallel
  # ~/.config/git/config and conflict with the xdg.configFile symlink.
  # The git package itself is provided via home.packages above.

  # Delta pager config (Catppuccin Mocha)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "diff-highlight line-numbers decorations";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow";
        file-decoration-style = "none";
      };
      line-numbers = {
        line-numbers-left-format = "  ";
        line-numbers-right-format = "  ›";
        line-numbers-minus-style = "red";
        line-numbers-plus-style = "green";
      };
      navigate = {
        n = "true";
      };
      side-by-side = true;
      syntax-theme = "Catppuccin Mocha";
      pager = "less --mouse --wheel-lines=3 --quit-on-intr";
      dark = "Catppuccin Mocha";
      light = "Catppuccin Latte";
    };
  };

  # gh CLI config
  programs.gh = {
    enable = true;
    settings = {
      editor = "nvim";
      prompt = "enabled";
      pager = "delta";
      alias = {
        co = "pr checkout";
        rs = "pr review:approve";
      };
    };
  };
}