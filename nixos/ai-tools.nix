{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.ai-tools.enable = lib.mkEnableOption "Enable shared ai-tools config";

  config = lib.mkIf config.shared-config.ai-tools.enable {
    home.packages = with pkgs; [
      code-cursor
    ];
  };
}
