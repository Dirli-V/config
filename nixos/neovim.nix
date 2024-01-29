{pkgs, ...}: {
  xdg.configFile.nvim.source = ../nvim;
  home.packages = with pkgs; [
    ripgrep
    # python needed for ghost
    python3
    python311Packages.pynvim
    python311Packages.requests
    python311Packages.simple-websocket-server
  ];
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
