{pkgs, ...}: {
  xdg.configFile.wezterm.source = ../wezterm;
  home.packages = [pkgs.wezterm];
}
