inputs: {
  lib,
  config,
  ...
}: {
  options.shared-config.astal.enable = lib.mkEnableOption "Enable shared astal config";

  config = lib.mkIf config.shared-config.astal.enable {
    home.packages = [(import ../astal/package.nix inputs "x86_64-linux")];
  };
}
