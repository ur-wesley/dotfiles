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
  # Security: passwordless doas for wheel group
  ####################
  security.doas = {
    enable = true;
    extraRules = [{
      groups = [ "wheel" ];
      noPass = true;
    }];
  };

  ####################
  # Services
  ####################
  services = {
    dbus.enable = true;
    tailscale.enable = true;
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
  # WSL workaround: doas needs the setuid bit, but the Nix store
  # is on a separate ext4 partition that's remounted read-only
  # during activation. A systemd oneshot service fixes it on boot.
  ####################
  systemd.services.doas-setuid = {
    description = "Set doas setuid bit (WSL workaround)";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "doas-setuid" ''
        for doas_path in /nix/store/*-doas*/bin/doas; do
          if [ -f "$doas_path" ] && [ ! -u "$doas_path" ]; then
            ${pkgs.coreutils}/bin/chmod 4755 "$doas_path"
          fi
        done
      '';
    };
  };

  ####################
  # System state version
  ####################
  system.stateVersion = "26.05";
}
