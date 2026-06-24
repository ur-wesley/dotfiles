{ config, pkgs, lib, ... }:

{
  imports = [ ];

  ####################
  # WSL-specific
  ####################
  wsl = {
    enable = true;
    defaultUser = "wesley";
    wslConf = {
      boot = {
        systemd = true;
      };
      user = {
        default = "wesley";
      };
      interop = {
        enabled = true;
        appendWindowsPath = false;
      };
      automount = {
        enabled = true;
        mountFsTab = true;
        root = "/mnt";
        options = "metadata,umask=22,fmask=11";
        ldconfig = false;
      };
      network = {
        generateHosts = true;
        generateResolvConf = true;
      };
    };
  };

  ####################
  # Bootloader (no-op for WSL but NixOS still wants it)
  ####################
  boot.loader.grub.enable = false;
  fileSystems."/" = { device = "/dev/sda"; fsType = "ext4"; };

  ####################
  # Networking
  ####################
  networking.hostName = "Dev";
  networking.useDHCP = lib.mkDefault true;

  ####################
  # Nix settings
  ####################
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "wesley" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  ####################
  # Allow unfree packages
  ####################
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-ms-dotnettools-csharp"
      "cmp-emoji"
      "telescope-fzf-native-nvim"
    ];
  };

  ####################
  # Locale & timezone
  ####################
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  ####################
  # Console keymap
  ####################
  console.keyMap = "de";

  ####################
  # Users
  ####################
  users.users.wesley = {
    isNormalUser = true;
    home = "/home/wesley";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialHashedPassword = "";
  };

  ####################
  # System packages (minimal - rest is in home-manager)
  ####################
  environment.systemPackages = with pkgs; [
    vim  # fallback
    git
    cacert
    openssl
  ];

  ####################
  # Security: allow sudo without password for wheel
  ####################
  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = false;
  };

  ####################
  # Services
  ####################
  services = {
    dbus.enable = true;
  };

  ####################
  # Programs
  ####################
  programs = {
    bash.enable = true;
    zsh.enable = true;
    fish.enable = true;
    nix-ld.enable = true;
  };

  ####################
  # WSL-specific: setuid bit on sudo is lost on every rebuild because
  # the nix store is on a separate ext4 partition that's remounted ro
  # during activation. Run this once after each rebuild:
  #
  #   sudo chmod 4755 /nix/store/*-sudo-rs*/bin/sudo
  #
  # (The activation script can't fix this — it runs while the nix
  # store is read-only.)
  ####################

  ####################
  # System state version
  ####################
  system.stateVersion = "26.05";
}
