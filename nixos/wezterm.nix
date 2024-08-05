{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.wezterm.enable = lib.mkEnableOption "Enable shared wezterm config";

  config = lib.mkIf config.shared-config.wezterm.enable {
    xdg.configFile.wezterm.source = ../wezterm;
    home.packages = [pkgs.wezterm];
  };
}
