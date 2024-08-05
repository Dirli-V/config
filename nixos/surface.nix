{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./surface-hardware-configuration.nix
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
    hostName = "dirli-surface";
    networkmanager.enable = true;
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
      timeout = 0;
    };
  };

  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
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

  # List packages installed in system profile. To search, run:
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];
  home-manager = {
    users.dirli = {
      config,
      pkgs,
      ...
    }: let
      config-files = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config";
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
        ltex-ls
        cargo-nextest
        ripgrep
        python3
        python3Packages.autopep8
        python3Packages.debugpy
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
        proselint
        codespell
        inlyne
        spotify
        _1password-gui
        helix
        lm_sensors
        du-dust
        signal-desktop
        thunderbird
        # x things
        xdotool
        xorg.xdpyinfo
        wmctrl
        xclip
        # end of x things
        p7zip
        zoxide
      ];
      xdg.configFile = {
        nushell.source = "${config-files}/nushell";
        helix.source = "${config-files}/helix";
        "starship.toml".source = "${config-files}/starship.toml";
        wezterm.source = "${config-files}/wezterm";
        sway.source = "${config-files}/sway";
        k9s.source = "${config-files}/k9s";
        "window_mover.yaml".source = "${config-files}/window_mover.yaml";
        ".ideavimrc".source = "${config-files}/.ideavimrc";
        nvim.source = "${config-files}/nvim";
        btop.source = "${config-files}/btop";
      };

      home.stateVersion = "22.11";
      programs = {
        home-manager.enable = true;

        git = {
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

        neovim = {
          enable = true;
        };

        fzf.enable = true;
      };
    };
    useUserPackages = true;
    useGlobalPkgs = true;
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
