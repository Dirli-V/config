{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.sql-tools.enable = lib.mkEnableOption "Enable shared sql-tools config";

  config = lib.mkIf config.shared-config.sql-tools.enable {
    home.packages = with pkgs; [
      dbeaver-bin
    ];
  };
}
