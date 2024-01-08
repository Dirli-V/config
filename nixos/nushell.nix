{pkgs, ...}: {
  xdg.configFile.nushell.source = ../nushell;
  home.packages = [
    pkgs.nushell
    pkgs.zoxide
  ];
}
