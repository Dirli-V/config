{pkgs, ...}: {
  xdg.configFile.alacritty.source = ../alacritty;
  home.packages = [pkgs.alacritty];
}
