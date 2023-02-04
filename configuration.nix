{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../hardware-configuration.nix
      <home-manager/nixos>
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  networking.hostName = "dirli-nixos";
  networking.networkmanager.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

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

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Don't forget to set a password with ‘passwd’.
  users.users.dirli = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video" ];
    shell = pkgs.nushell;
  };
  security.pam.services.swaylock = {
    text = "auth include login";
  };
  security.polkit.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.package = pkgs.mesa.drivers;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.package32 = pkgs.pkgsi686Linux.mesa.drivers;
  hardware.bluetooth.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  environment.variables = rec {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  home-manager.users.dirli = { pkgs, ... }: {
    home.packages = with pkgs; [
      # sway start
      swaylock
      swayidle
      wl-clipboard
      mako
      alacritty
      wofi
      waybar
      # sway end
      brave
      discord
      nodejs
      nodePackages.cspell
      nodePackages.jsonlint
      nodePackages.stylelint
      nodePackages.vscode-json-languageserver
      rustup
      ripgrep
      python3
      python3Packages.autopep8
      python3Packages.debugpy
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
      rust-analyzer
      spotify
      steam
      steamcmd
      steam-tui
      wine
      _1password-gui
      helix
      lm_sensors
      du-dust
      signal-desktop
      thunderbird
    ];
    xdg.configFile.nushell = {
      source = ./nushell;
      recursive = true;
    };
    xdg.configFile.helix = {
      source = ./helix;
      recursive = true;
    };
    xdg.configFile."starship.toml" = {
      source = ./starship.toml;
    };
    xdg.configFile.wezterm = {
      source = ./wezterm;
      recursive = true;
    };
    xdg.configFile.sway = {
      source = ./sway;
      recursive = true;
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

    xdg.configFile.nvim = {
      source = ./nvim;
      recursive = true;
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.fzf.enable = true;
  };
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
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
  ];

  # Keep a list of all installed packages in /etc/current-systempackages
  environment.etc."current-systempackages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
    formatted;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

