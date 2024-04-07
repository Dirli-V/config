{
  pkgs,
  inputs,
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
  xdg.configFile.scape.source = ../scape;
  home.packages = [
    inputs.scape.packages.x86_64-linux.default
    start_scape_systemd_session
    pkgs.xwayland
  ];
}
