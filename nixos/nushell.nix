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

    home.packages = [
      pkgs.nushell
      pkgs.zoxide
      pkgs.atuin
    ];
  };
}
