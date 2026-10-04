dms: {
  lib,
  config,
  ...
}: {
  imports = [dms.homeModules.dank-material-shell];

  options.shared-config.dms.enable = lib.mkEnableOption "Enable shared DankMaterialShell config";

  config = lib.mkIf config.shared-config.dms.enable {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      settings = {
        dankBarSpacing = 0;
        dankBarSquareCorners = true;
      };
    };
  };
}
