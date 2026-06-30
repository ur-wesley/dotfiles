{ config, pkgs, lib, ... }:

{
  # Zellij — terminal multiplexer, default daily-driver.
  # Replaces Rio (rio.config.toml has been deleted; zellij provides the
  # same split-pane workflow with proper session persistence).
  home.packages = with pkgs; [
    zellij
  ];

  # Zellij config + theme + layouts are sourced from dotfiles/config/zellij/.
  # home-manager mirrors the structure into ~/.config/zellij/.
  #
  # The theme (themes/catppuccin-mocha.kdl) and layouts (layouts/dev.kdl)
  # are picked up automatically by zellij because they're in standard
  # subdirectories relative to config.yaml.
  xdg.configFile."zellij/config.yaml".source = ../../dotfiles/config/zellij/config.yaml;
  xdg.configFile."zellij/themes/catppuccin-mocha.kdl".source = ../../dotfiles/config/zellij/themes/catppuccin-mocha.kdl;
  xdg.configFile."zellij/layouts/dev.kdl".source = ../../dotfiles/config/zellij/layouts/dev.kdl;
}