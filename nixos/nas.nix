{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nas-hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  networking = {
    hostName = "nas";
    networkmanager.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "de_AT.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  services.fwupd.enable = true;

  users.users.nas = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = [
      # Add SSH public key(s) here
    ];
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    btop
    cmake
    gnumake
    gcc
    unzip
    zip
    lldb
    nixos-option
    killall
    nix-index
    libGL
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
