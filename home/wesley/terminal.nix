{ config, pkgs, lib, ... }:

{
  # NOTE: WezTerm (on the Windows side) is the terminal multiplexer.
  # We don't need tmux/zellij inside the WSL distro.
  # Both are kept as binaries (no home-manager config) as a fallback
  # for raw SSH sessions or if you ever need a detached session.

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
