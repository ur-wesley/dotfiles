{ config, pkgs, lib, nixvim, ... }:

{
  imports = [
    ./core.nix
    ./zsh.nix
    ./git.nix
    ./terminal.nix
    ./cli-tools.nix
    ./dev-tools.nix
    ./nvim.nix
    ./helix.nix
    ./wezterm.nix
  ];

  home = {
    username = "wesley";
    homeDirectory = "/home/wesley";
    stateVersion = "26.05";

    # Allow home-manager to manage /etc/profiles (per-user)
    packages = with pkgs; [];
  };

  # Pass the nixvim package and module to nvim.nix via these options
  # (so nvim.nix doesn't need to know about the flake input)
  programs.nixvim = {
    enable = true;
    package = nixvim.packages.${pkgs.stdenv.hostPlatform.system}.nixvim;
  };

  # Let home-manager install unfree packages (omnisharp, jetbrains, etc.)
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-ms-dotnettools-csharp"
    ];
  };
}
