{ config, pkgs, lib, ... }:

{
  # WezTerm — GPU-accelerated Windows terminal, optional alternative to
  # Rio (dotfiles/config/rio). Both are GUI shells that host Zellij.
  # The Windows binary is installed via winget (wez.wezterm) — see
  # install/install.ps1. The WSL side just symlinks the shared config.
  xdg.configFile."wezterm/wezterm.lua".source = ../../dotfiles/config/wezterm/wezterm.lua;
}
