{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.eww.enable = lib.mkEnableOption "Enable shared eww config";

  config = lib.mkIf config.shared-config.eww.enable {
    xdg.configFile.eww.source = ../eww;
    home.packages = [pkgs.eww];
  };
}
