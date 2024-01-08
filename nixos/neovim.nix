{pkgs, ...}: {
  xdg.configFile.nvim.source = ../nvim;
  home.packages = [pkgs.ripgrep];
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
