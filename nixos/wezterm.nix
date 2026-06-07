{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  # use input wezterm if available
  wezterm =
    if builtins.hasAttr "wezterm" inputs
    then inputs.wezterm.packages.${pkgs.system}.default
    else pkgs.wezterm;
in {
  options.shared-config.wezterm.enable = lib.mkEnableOption "Enable shared wezterm config";

  config = lib.mkIf config.shared-config.wezterm.enable {
    xdg.configFile.wezterm.source = ../wezterm;
    home.packages =
      if config.targets.genericLinux.nixGL.packages == null
      then [wezterm]
      else [(config.lib.nixGL.wrap wezterm)];
  };
}
