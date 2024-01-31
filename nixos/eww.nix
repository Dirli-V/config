{pkgs, ...}: {
  xdg.configFile.eww.source = ../eww;
  home.packages = [pkgs.eww];
}
