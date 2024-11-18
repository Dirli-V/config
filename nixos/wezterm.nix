{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.wezterm.enable = lib.mkEnableOption "Enable shared wezterm config";

  config = lib.mkIf config.shared-config.wezterm.enable {
    xdg.configFile.wezterm.source = ../wezterm;
    home.packages =
      if config.nixGL.packages == null
      then [pkgs.wezterm]
      else [(config.lib.nixGL.wrap pkgs.wezterm)];
  };
}
