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
    (import ./nixos-default.nix inputs)
  ];
  nixpkgs.overlays = [
    inputs.wired-notify.overlays.default
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "android-studio-stable"
      "discord"
      "hplip"
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
    ];

  shared-config.base.enable = true;

  networking = {
    hostName = "dirli-nixos";
  };

  boot = {
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
      wireplumber = {
        enable = true;
        extraConfig = {
          "10-activate_bose" = {
            "monitor.alsa.rules" = [
              {
                "matches" = [
                  {
                    "node.description" = "Bose Mini SoundLink";
                  }
                ];
                "actions" = {
                  "update-props" = {
                    "priority.session" = 1010;
                  };
                };
              }
              {
                "matches" = [
                  {
                    "node.nick" = "Stealth Pro Xbox";
                  }
                ];
                "actions" = {
                  "update-props" = {
                    "priority.session" = 1009;
                  };
                };
              }
            ];
          };
        };
      };
    };

    printing.enable = true;
    # http://localhost:631/admin/
    printing.drivers = [
      pkgs.gutenprint
      pkgs.gutenprintBin
      pkgs.hplip
      pkgs.hplipWithPlugin
    ];

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

    flatpak.enable = true;
    gvfs.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
    };
  };

  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      name = "Breeze";
      size = 24;
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
    graphics = {
      enable = true;
      enable32Bit = true;
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
    users.dirli = {pkgs, ...}: {
      imports = [
        (import ./hm-default.nix inputs)
      ];

      stylix.targets.hyprpaper.enable = lib.mkForce false;
      stylix.targets.hyprland.enable = lib.mkForce false;

      shared-config = {
        ags.enable = true;
        alacritty.enable = true;
        dev-tools.enable = true;
        helix.enable = true;
        ideavim.enable = true;
        k9s.enable = true;
        neovim.enable = true;
        nushell.enable = true;
        scape.enable = true;
        starship.enable = true;
        wezterm.enable = true;
      };

      home = {
        packages = with pkgs; [
          brave
          discord
          spotify
          steam
          gamemode
          _1password-gui
          signal-desktop
          thunderbird
          yazi
          android-studio
          qalculate-qt
          joplin-desktop
          sniffnet
          helvum
          playerctl
          libnotify
          swaylock
          grim
          slurp
          swappy
          zed-editor
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
          onagre
          wl-clipboard-rs
          xwaylandvideobridge
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
    steam = {
      enable = true;
      extest.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  environment.systemPackages = [
    config.boot.kernelPackages.perf
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
