{ config, pkgs, lib, ... }:

{
  # Shell prompt + history
  home.packages = with pkgs; [
    starship
    atuin
    mcfly
    zoxide
    # Dotfiles management — drives dotfiles/Makefile + stow.sh.
    stow
  ];

  # fzf shell integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [ "-p 60%" ];
    };
  };

  # zoxide — smart cd. `cd` is replaced with `z` and we also
  # override `cd` itself so it just works transparently.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # direnv with nix-direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Atuin shell history
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
      style = "auto";
      # Up arrow cycles through history inline (native shell feel) instead
      # of opening the atuin TUI. Use Ctrl-Up (or the search keybind) to
      # open the full fuzzy search.
      up_arrow_mapping = "shell";
    };
  };

  # mcfly shell history
  programs.mcfly = {
    enable = true;
    enableFishIntegration = true;
    keyScheme = "vim";
  };

  # Starship prompt — config is sourced from dotfiles/config/starship/starship.toml
  # so home-manager (WSL) and stow (Windows) share one file.
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  # Source the starship config from dotfiles/. Home-manager will symlink
  # ~/.config/starship.toml into the Nix store pointing at this file.
  # If a Nix store symlink already exists, run `stow --restow` to overwrite it.
  xdg.configFile."starship.toml".source = ../../dotfiles/config/starship/starship.toml;
}
