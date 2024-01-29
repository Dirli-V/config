{pkgs, ...}: {
  xdg.configFile.nvim.source = ../nvim;
  home.packages = with pkgs; [
    ripgrep
    libgccjit
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
      withPython3 = false; # disable here, because python3 is available globally
    };
  };
}
