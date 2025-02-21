{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.rust-tools.enable = lib.mkEnableOption "Enable shared rust-tools config";

  config = lib.mkIf config.shared-config.rust-tools.enable {
    home.packages = with pkgs; [
      taplo
      cargo
    ];
  };
}
