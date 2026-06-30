{ config, pkgs, lib, ... }:

{
  # Television — Rust fuzzy finder (TUI alternative to fzf).
  # Channels are auto-loaded from ~/.config/television/channels/*.toml.
  home.packages = with pkgs; [
    television
  ];

  # Television config + 5 channels sourced from dotfiles/config/television/.
  xdg.configFile."television/config.toml".source = ../../dotfiles/config/television/config.toml;
  xdg.configFile."television/channels/files.toml".source = ../../dotfiles/config/television/channels/files.toml;
  xdg.configFile."television/channels/git-files.toml".source = ../../dotfiles/config/television/channels/git-files.toml;
  xdg.configFile."television/channels/env.toml".source = ../../dotfiles/config/television/channels/env.toml;
  xdg.configFile."television/channels/recent.toml".source = ../../dotfiles/config/television/channels/recent.toml;
  xdg.configFile."television/channels/projects.toml".source = ../../dotfiles/config/television/channels/projects.toml;
}