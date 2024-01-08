{pkgs, ...}: {
  xdg.configFile.btop.source = ../btop;
  home.packages = [pkgs.btop];
}
