{pkgs, ...}: {
  xdg.configFile.helix.source = ../helix;
  home.packages = [pkgs.helix];
}
