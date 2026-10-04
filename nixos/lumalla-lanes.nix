{
  lib,
  config,
  ...
}: {
  options.shared-config.lumalla-lanes.enable = lib.mkEnableOption "Enable shared Lumalla lanes config";

  config = lib.mkIf config.shared-config.lumalla-lanes.enable {
    xdg.configFile."lumalla/lanes.lua".source = ../lumalla/lanes.lua;
  };
}
