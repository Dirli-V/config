ags: {
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [ags.homeManagerModules.default];

  options.shared-config.ags.enable = lib.mkEnableOption "Enable shared ags config";

  config = lib.mkIf config.shared-config.ags.enable {
    programs.ags = {
      enable = true;

      configDir = ../ags;

      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };
  };
}
