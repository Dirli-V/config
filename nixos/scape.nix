scape: {
  pkgs,
  config,
  lib,
  ...
}: let
  start_scape_systemd_session =
    pkgs.writeShellApplication
    {
      name = "start_scape_systemd_session";
      runtimeInputs = [
      ];
      text = ''
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY
        systemctl --user start scape-session.target
      '';
    };
in {
  options.shared-config.scape.enable = lib.mkEnableOption "Enable shared scape config";

  config = lib.mkIf config.shared-config.scape.enable {
    xdg.configFile.scape.source = ../scape;
    home.packages = [
      scape.packages.x86_64-linux.default
      start_scape_systemd_session
      pkgs.xwayland
    ];
  };
}
