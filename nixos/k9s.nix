{
  pkgs,
  lib,
  config,
  ...
}: let
  configFiles = lib.attrsets.concatMapAttrs (filename: _: {
    "k9s/${filename}".source = ../k9s/${filename};
  }) (builtins.readDir ../k9s);
in {
  xdg.configFile =
    configFiles
    // {
      "k9s/config.yml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/k9s/config.yml";
    };

  home.packages = [pkgs.k9s];
}
