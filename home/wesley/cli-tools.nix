{ config, pkgs, lib, ... }:

{
  # Modern CLI replacements
  home.packages = with pkgs; [
    # ls / cat / grep / find
    eza
    bat
    ripgrep
    fd

    # JSON / YAML
    jq
    yq
    fx

    # sed / cut
    sd
    choose

    # du / df / ps / top
    dust
    duf
    procs
    btop
    glances
    zenith

    # Stats
    tokei
    hyperfine
    gping

    # Network
    mtr
    dog
    bandwhich
    httpie
    xh
    curlie

    # Misc
    choose
    imagemagick
    vivid  # ls colors

    # Editors (helix is a post-modern modal editor with LSP built-in)
    helix

    # CLI dev tools
    gh                              # GitHub CLI
    opencode                        # opencode AI coding CLI
    claude-code                     # Anthropic Claude Code CLI
  ];

  # Better diff
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };
}
