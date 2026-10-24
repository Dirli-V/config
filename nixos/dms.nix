dms: {
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [dms.homeModules.dank-material-shell];

  options.shared-config.dms.enable = lib.mkEnableOption "Enable shared DankMaterialShell config";

  config = lib.mkIf config.shared-config.dms.enable {
    home.packages = [pkgs.gh];

    xdg.configFile."DankMaterialShell/plugins/githubReviews".source = ../dms/plugins/githubReviews;

    home.activation.enableGithubReviewsPlugin = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/DankMaterialShell"
      ${pkgs.python3}/bin/python3 ${../dms/plugins/githubReviews/enable.py} \
        "$HOME/.config/DankMaterialShell/plugin_settings.json"
    '';

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
