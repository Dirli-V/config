# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./surface-hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "dirli-surface"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "at";
    xkbVariant = "";
  };
  
  virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dirli = {
    isNormalUser = true;
    description = "Dirli";
    extraGroups = [ "networkmanager" "wheel" "user-with-access-to-virtualbox" ];
    shell = pkgs.nushell;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
 fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  home-manager.users.dirli = { config, pkgs, ... }:
  let
    config-files = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/config";
  in
  {
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
      rustup
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
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
