{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.alacritty.enable = lib.mkEnableOption "Enable shared alacritty config";

  config = lib.mkIf config.shared-config.alacritty.enable {
    xdg.configFile.alacritty.source = ../alacritty;
    home.packages = [pkgs.alacritty];
  };
}
