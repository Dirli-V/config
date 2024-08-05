{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.btop.enable = lib.mkEnableOption "Enable shared btop config";

  config = lib.mkIf config.shared-config.btop.enable {
    xdg.configFile.btop.source = ../btop;
    home.packages = [pkgs.btop];
  };
}
