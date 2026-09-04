{
  pkgs,
  lib,
  config,
  ...
}: let
  configFiles = lib.attrsets.concatMapAttrs (filename: _: {
    "nushell/${filename}".source = ../nushell/${filename};
  }) (builtins.readDir ../nushell);
in {
  options.shared-config.nushell.enable = lib.mkEnableOption "Enable shared nushell config";

  config = lib.mkIf config.shared-config.nushell.enable {
    xdg.configFile =
      configFiles
      // {
        # "nushell/history.txt".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/nushell/history.txt";
        atuin.source = ../atuin;
      };

    # `nd` (nushell/nix.nu) drives direnv directly via `direnv exec`; it does not
    # use the shell hook, so the auto-load integrations stay off.
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      # Hide the routine "loading .envrc / using flake / Using cached dev shell"
      # chatter -- `nd` runs on every new wezterm tab. Only messages matching this
      # filter are shown, so failures, blocked .envrc files and cold-cache
      # rebuilds still surface.
      config.global.log_filter = "(failed|error|denied|invalidated|not allowed|Renewed)";
    };

    home.packages = with pkgs; [
      nushell
      zoxide
      atuin
      fd
      xplr
    ];
  };
}
