{
  description = "Wesley's NixOS-WSL flake (NixOS 26.05 unstable, home-manager, Nixvim)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, nixvim, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.nixos-wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit nixvim; };
        modules = [
          nixos-wsl.nixosModules.wsl
          ./hosts/nixos-wsl/configuration.nix
          home-manager.nixosModules.home-manager
          ({ lib, nixvim, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit nixvim; };
              sharedModules = [ nixvim.homeModules.nixvim ];
              users.wesley = { config, pkgs, lib, ... }: {
                # Use nixvim's pinned nixpkgs to suppress follow warning
                programs.nixvim.nixpkgs.source = nixvim.inputs.nixpkgs;
                programs.fish.enable = true;
                imports = [
                  ./home/wesley/core.nix
                  ./home/wesley/fish.nix
                  ./home/wesley/zsh.nix
                  ./home/wesley/bash.nix
                  ./home/wesley/git.nix
                  ./home/wesley/terminal.nix
                  ./home/wesley/cli-tools.nix
                  ./home/wesley/dev-tools.nix
                  ./home/wesley/zellij.nix
                  ./home/wesley/television.nix
                  ./home/wesley/nvim.nix
                  ./home/wesley/helix.nix
                  ./home/wesley/wezterm.nix
                ];
                home = {
                  username = "wesley";
                  homeDirectory = "/home/wesley";
                  stateVersion = "26.05";
                };
                programs.nixvim = {
                  enable = true;
                };
              };
            };
          })
        ];
      };
    };
}
