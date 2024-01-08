{pkgs, ...}: {
  xdg.configFile.k9s.source = ../k9s;
  home.packages = [pkgs.k9s];
}
