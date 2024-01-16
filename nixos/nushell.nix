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
  xdg.configFile =
    configFiles
    // {
      "nushell/history.txt".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/nushell/history.txt";
      atuin.source = ../atuin;
    };

  home.packages = [
    pkgs.nushell
    pkgs.zoxide
    pkgs.atuin
  ];
}
