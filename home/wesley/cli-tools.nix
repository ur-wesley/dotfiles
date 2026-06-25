{ config, pkgs, lib, ... }:

let
  # Pin opencode to the latest upstream release. nixpkgs/nixos-unstable
  # lags a few patches behind opencode's own releases — we override
  # version + src to follow upstream without waiting on nixpkgs.
  # To bump: update `version` + `hash` below (the `hash` placeholder
  # shows the expected SRI length so the build error prints the
  # right value on first try).
  opencode-latest = pkgs.opencode.overrideAttrs (old: {
    version = "1.17.10";
    src = pkgs.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v1.17.10";
      hash = "sha256-QWdAKbyu/fV6Ejh+x63xDZMPVDoWDha0vk298Fv8IDc=";
    };
    # The bundled `node_modules` derivation has its own outputHash
    # pinned to the old source — clear it so Nix recomputes from
    # the new src on first build.
    node_modules = old.node_modules.overrideAttrs (_: {
      outputHash = "";
    });
  });
in
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
    opencode-latest                 # opencode AI coding CLI (pinned to latest)
    claude-code                     # Anthropic Claude Code CLI
  ];

  # Better diff
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };
}
