{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.helix.enable = lib.mkEnableOption "Enable shared helix config";

  config = lib.mkIf config.shared-config.helix.enable {
    xdg.configFile.helix.source = ../helix;
    home.packages = [pkgs.helix];
  };
}
