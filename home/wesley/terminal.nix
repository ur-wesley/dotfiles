{ config, pkgs, lib, ... }:

{
  # NOTE: Rio (on the Windows side) is the daily-driver terminal.
  # tmux/zellij binaries are kept as a fallback for raw SSH sessions
  # or if you ever need a detached session; we do not autostart them.

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
