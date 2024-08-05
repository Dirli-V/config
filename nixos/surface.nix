{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./surface-hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    (import ./nixos-default.nix inputs)
  ];
  nixpkgs.overlays = [
    inputs.wired-notify.overlays.default
  ];

  shared-config.base.enable = true;

  networking = {
    hostName = "dirli-surface";
  };

  hardware.bluetooth.enable = true;

  services = {
    xserver = {
      enable = true;

      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;

      layout = "at";
      xkbVariant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
    pipewire = {
      enable = true;
    };
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dirli = {
    isNormalUser = true;
    description = "Dirli";
    extraGroups = ["networkmanager" "wheel" "user-with-access-to-virtualbox"];
    shell = pkgs.nushell;
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];
  home-manager = {
    users.dirli = {pkgs, ...}: {
      imports = [
        (import ./hm-default.nix inputs)
      ];

      stylix.targets.hyprpaper.enable = lib.mkForce false;
      stylix.targets.hyprland.enable = lib.mkForce false;

      shared-config = {
        alacritty.enable = true;
        dev-tools.enable = true;
        helix.enable = true;
        ideavim.enable = true;
        k9s.enable = true;
        neovim.enable = true;
        nushell.enable = true;
        starship.enable = true;
        wezterm.enable = true;
      };

      home.packages = with pkgs; [
        brave
        discord
        cargo-nextest
        spotify
        _1password-gui
        signal-desktop
        thunderbird
      ];

      home.stateVersion = "22.11";
      programs = {
        home-manager.enable = true;

        git = {
          userName = "Dirli-V";
          userEmail = "github@dirli.net";
        };
      };
    };
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  environment.systemPackages = with pkgs; [
    cmake
    gnumake
    gcc
    unzip
    zip
    lldb
    nixos-option
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
