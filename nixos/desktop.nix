{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./desktop-hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
  ];
  nixpkgs.overlays = [
    inputs.wired-notify.overlays.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 30d";
    # };
  };

  networking = {
    hostName = "dirli-nixos";
    networkmanager.enable = true;
  };
  boot = {
    loader = {
      # boot.kernelPackages = pkgs.linuxPackages_latest;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    kernelModules = ["kvm-amd" "kvm-intel"];
    binfmt.emulatedSystems = ["aarch64-linux"];
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    printing.enable = true;
    # http://localhost:631/admin/
    printing.drivers = [
      pkgs.gutenprint
      pkgs.gutenprintBin
      pkgs.hplip
      pkgs.hplipWithPlugin
    ];
    # xserver = {
    #   enable = true;
    #   displayManager.sddm.enable = true;
    #   desktopManager.plasma5.enable = true;

    # systemd.services.lemurs = {
    #   description = "Lemurs";
    #   after = [
    #     "systemd-user-sessions.service"
    #     "plymouth-quit-wait.service"
    #     "getty@tty3.service"
    #   ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.lemurs}/bin/lemurs";
    #     StandardInput = "tty";
    #     TTYPath = "/dev/tty3";
    #     TTYReset = "yes";
    #     TTYVHangup = "yes";
    #     Type = "idle";
    #   };
    #   aliases = [
    #     "display-manager.service"
    #   ];
    # };
    #
    # };

    fwupd.enable = true;

    pcscd.enable = true;

    udev.extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

      # Wally Flashing rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      # Wally Flashing rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11",     MODE:="0666",     SYMLINK+="stm32_dfu"
    '';
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-wlr
        # xdg-desktop-portal-gtk
      ];
    };
  };

  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "de_AT.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  stylix = {
    image = ./wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      name = "Breeze";
      package = pkgs.runCommand "Breeze_Dark_Default-package" {} ''
        mkdir -p $out/share/icons/Breeze
        cp -r ${../cursor/Breeze_Dark_Default}/* $out/share/icons/Breeze
      '';
    };
  };

  systemd.user.targets."scape-session" = {
    description = "Scape graphical session init service";
    bindsTo = ["graphical-session.target"];
    wants = ["graphical-session-pre.target"];
    after = ["graphical-session-pre.target"];
  };

  # Don't forget to set a password with ‘passwd’.
  users.users.dirli = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "video" "libvirtd" "adbusers" "plugdev"];
    shell = pkgs.nushell;
  };
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.dirli.gnupg.enable = true;
    pam.services.swaylock = {};
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    bluetooth.enable = true;
  };
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    useUserPackages = true;
    useGlobalPkgs = true;
    users.dirli = {
      config,
      pkgs,
      ...
    }: let
      config-files = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config";
      # personal-config-files = config.lib.file.mkOutOfStoreSymlink "/home/dirli/personal_config";
    in {
      imports = [
        inputs.wired-notify.homeManagerModules.default
        ./neovim.nix
        ./alacritty.nix
        ./nushell.nix
        ./starship.nix
        ./wezterm.nix
        ./k9s.nix
        ./helix.nix
        ./eww.nix
        ./btop.nix
        ./dev-tools.nix
        ./ideavim.nix
        ./wired-notify.nix
        ./scape.nix
      ];

      xdg.configFile = {
        "window_mover.yaml".source = "${config-files}/window_mover.yaml";
      };
      home = {
        packages = with pkgs; [
          brave
          discord
          packer
          hcloud
          opentofu
          spotify
          steam
          _1password-gui
          signal-desktop
          thunderbird
          lutris
          (wineWowPackages.full.override {
            wineRelease = "staging";
            mingwSupport = true;
          })
          winetricks
          bottles
          heroic
          # x things
          xdotool
          xorg.xdpyinfo
          wmctrl
          xclip
          # end of x things
          android-studio
          qalculate-qt
          stremio
          joplin-desktop
          sniffnet
          sops
          helvum
          playerctl
          libnotify
          swaylock
          grim
          slurp
          swappy
          (writeShellApplication
            {
              name = "make-screenshot";
              runtimeInputs = [
                grim
                slurp
                swappy
              ];
              text = ''
                grim -g "$(slurp)" - | swappy -f -
              '';
            })
          # onagre
          wl-clipboard-rs
        ];

        stateVersion = "22.11";
      };
      programs = {
        home-manager.enable = true;

        git = {
          userName = "Dirli-V";
          userEmail = "github@dirli.net";
        };
      };
    };
  };
  programs = {
    kdeconnect.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    btop
    htop
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
    # lemurs
    gnupg
    pinentry-qt
  ];

  # Keep a list of all installed packages in /etc/current-systempackages
  # environment.etc."current-systempackages".text = let
  #   packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
  #   sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
  #   formatted = builtins.concatStringsSep "\n" sortedUnique;
  # in
  #   formatted;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
