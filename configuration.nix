{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../hardware-configuration.nix
    <home-manager/nixos>
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.kernelModules = ["kvm-amd" "kvm-intel"];
  virtualisation.libvirtd.enable = true;

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
  # services.xserver.videoDrivers = ["modesetting"];
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
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Don't forget to set a password with ‘passwd’.
  users.users.dirli = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "video" "libvirtd" "adbusers"];
    shell = pkgs.nushell;
  };
  security.polkit.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.bluetooth.enable = true;
  programs.adb.enable = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];
  home-manager.users.dirli = {
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
      ruff
      taplo
      ltex-ls
      rustup
      rnix-lsp
      alejandra
      deadnix
      statix
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
      rust-analyzer
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
      looking-glass-client
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
      btop.source = ./btop;
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
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

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
