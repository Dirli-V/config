astal: {
  lib,
  pkgs,
  config,
  system,
  ...
}: {
  imports = [ags.homeManagerModules.default];

  options.shared-config.astal.enable = lib.mkEnableOption "Enable shared astal config";

  config = lib.mkIf config.shared-config.astal.enable {
    home.packages = [import ../astal/package.nix inputs system];
  };
}
