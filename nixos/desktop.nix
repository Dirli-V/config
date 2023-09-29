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

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.kernelModules = ["kvm-amd" "kvm-intel"];
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  virtualisation.libvirtd.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.printing.enable = true;
  # http://localhost:631/admin/
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.gutenprintBin
    pkgs.hplip
    pkgs.hplipWithPlugin
  ];

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

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
  services.xserver.videoDrivers = ["modesetting"];
  programs.kdeconnect.enable = true;

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

  # Don't forget to set a password with ‘passwd’.
  users.users.dirli = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "video" "libvirtd" "adbusers" "plugdev"];
    shell = pkgs.nushell;
  };
  security.polkit.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.bluetooth.enable = true;
  programs.adb.enable = true;
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.dirli = {
      config,
      pkgs,
      ...
    }: let
      config-files = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config";
      personal-config-files = config.lib.file.mkOutOfStoreSymlink "/home/dirli/personal_config";
    in {
      home.packages = with pkgs; [
        alacritty
        brave
        discord
        nodejs
        nodePackages.cspell
        nodePackages.jsonlint
        nodePackages.stylelint
        nodePackages.vscode-json-languageserver
        nodePackages.fixjson
        ruff
        taplo
        ltex-ls
        rustup
        nil
        alejandra
        deadnix
        statix
        cargo-nextest
        ripgrep
        python3
        python3Packages.autopep8
        python3Packages.debugpy
        luajitPackages.jsregexp
        sumneko-lua-language-server
        stylua
        fd
        xplr
        nushell
        starship
        wezterm
        bandwhich
        docker
        k9s
        terraform
        packer
        kubectl
        hcloud
        kubernetes-helm
        proselint
        codespell
        inlyne
        spotify
        spotify-tui
        cider
        steam
        wine
        _1password-gui
        helix
        lm_sensors
        du-dust
        signal-desktop
        thunderbird
        lutris
        # x things
        xdotool
        xorg.xdpyinfo
        wmctrl
        xclip
        # end of x things
        android-studio
        p7zip
        qalculate-qt
        mpv
        stremio
        zoxide
        joplin-desktop
        sniffnet
        # neomutt
        neomutt
        isync
        msmtp
        pass
        mutt-wizard
        lynx
        notmuch
        urlview
        # end of neomutt
        sops
      ];
      xdg.configFile = {
        alacritty.source = "${config-files}/alacritty";
        nushell.source = "${config-files}/nushell";
        helix.source = "${config-files}/helix";
        "starship.toml".source = "${config-files}/starship.toml";
        wezterm.source = "${config-files}/wezterm";
        k9s.source = "${config-files}/k9s";
        "window_mover.yaml".source = "${config-files}/window_mover.yaml";
        ".ideavimrc".source = "${config-files}/.ideavimrc";
        nvim.source = "${config-files}/nvim";
        btop.source = ../btop;
        mutt.source = "${personal-config-files}/mutt";
      };

      home.stateVersion = "22.11";

      programs.home-manager.enable = true;

      programs.git = {
        enable = true;
        userName = "Dirli-V";
        userEmail = "github@dirli.net";
        extraConfig = {
          core = {
            editor = "nvim";
          };
          push.autoSetupRemote = true;
          init.defaultBranch = "main";
        };
        difftastic = {
          enable = true;
        };
        lfs.enable = true;
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };

      programs.fzf.enable = true;
    };
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };

  services.pcscd.enable = true;

  systemd.timers."mw-mailsync" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "mw-mailsync.service";
    };
  };

  systemd.services."mw-mailsync" = {
    script = ''
      set -eu
      ${pkgs.mutt-wizard}/bin/mailsync
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "dirli";
    };
  };
  security.pam.services.dirli.gnupg.enable = true;

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
    # lemurs
    gnupg
    pinentry-qt
  ];

  services.udev.extraRules = ''
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
