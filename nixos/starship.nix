{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.starship.enable = lib.mkEnableOption "Enable shared starship config";

  config = lib.mkIf config.shared-config.starship.enable {
    xdg.configFile."starship.toml".source = ../starship.toml;
    home.packages = [pkgs.starship];
  };
}
