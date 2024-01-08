{pkgs, ...}: {
  xdg.configFile."starship.toml".source = ../starship.toml;
  home.packages = [pkgs.starship];
}
