{pkgs, ...}: {
  xdg.configFile.nvim.source = ../nvim;
  home.packages = with pkgs; [
    ripgrep
    libgccjit
  ];
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraPython3Packages = ps: with ps; [simple-websocket-server python-slugify];
    };
  };
}
