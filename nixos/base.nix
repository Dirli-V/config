inputs: {
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.base.enable = lib.mkEnableOption "Enable NixOs base config";

  config = lib.mkIf config.shared-config.base.enable {
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
      package = pkgs.lix;
    };

    networking = {
      networkmanager.enable = true;
    };

    time.timeZone = "Europe/Vienna";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_AT.UTF-8";
      LC_IDENTIFICATION = "de_AT.UTF-8";
      LC_MEASUREMENT = "de_AT.UTF-8";
      LC_MONETARY = "de_AT.UTF-8";
      LC_NAME = "de_AT.UTF-8";
      LC_NUMERIC = "de_AT.UTF-8";
      LC_PAPER = "de_AT.UTF-8";
      LC_TELEPHONE = "de_AT.UTF-8";
      LC_TIME = "de_AT.UTF-8";
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

    boot = {
      loader = {
        # boot.kernelPackages = pkgs.linuxPackages_latest;
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0;
      };
    };

    environment.systemPackages = [
      pkgs.vim
      pkgs.wget
      pkgs.htop
      pkgs.killall
    ];
  };
}
