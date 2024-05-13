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
  options.shared-config.k9s.enable = lib.mkEnableOption "Enable shared k9s config";

  config = lib.mkIf config.shared-config.k9s.enable {
    xdg.configFile =
      configFiles
      // {
        "k9s/config.yml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/k9s/config.yml";
      };

    home.packages = [pkgs.k9s];
  };
}
