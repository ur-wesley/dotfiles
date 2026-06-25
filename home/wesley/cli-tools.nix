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

    # Cheatsheet tools — `navi` for personal/fuzzy, `tldr` for
    # community-maintained short examples. Bind `navi` to <C-g>
    # in fish (see home/wesley/fish.nix).
    navi
    tldr
  ];

  # Ship personal navi cheatsheets alongside the package so they
  # show up the first time `navi` is invoked. The file at
  # `dotfiles/navi/welcome.yaml` is the source of truth — sync
  # from the repo with `install/sync.ps1` and re-run
  # `home-manager switch` to refresh.
  xdg.configFile."navi/welcome.yaml".source = ../../dotfiles/navi/welcome.yaml;

  # Better diff
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };
}
