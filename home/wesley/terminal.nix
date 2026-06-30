{ config, pkgs, lib, ... }:

{
  # NOTE: Zellij is the daily-driver terminal multiplexer (see home/wesley/zellij.nix).
  # It runs inside WSL on whichever Windows terminal you launch — Rio
  # (dotfiles/config/rio, Rust, simple) or WezTerm (dotfiles/config/wezterm,
  # GPU, blur, optional alt). Sessions persist across reboots.

  home.packages = with pkgs; [
    btop
    # TUI file managers + viewers
    yazi
    broot
    glow
    # Shells + nice-to-haves
    mosh
    trash-cli
    tldr
    pay-respects
    nix-ld
  ];

  # pay-respects (replacement for thefuck)
  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
  };
}
