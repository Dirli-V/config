{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.neovim.enable = lib.mkEnableOption "Enable shared neovim config";

  config = lib.mkIf config.shared-config.neovim.enable {
    xdg.configFile.nvim.source = ../nvim;
    home.packages = with pkgs; [
      ripgrep
      libgccjit
      fzf
      bat
      typos-lsp
      gopls
      intelephense
      vscode-json-languageserver
      taplo
      yaml-language-server
      basedpyright
      jq
      gnumake
      lazygit
    ];
    programs = {
      neovim = {
        enable = true;
        defaultEditor = true;
        extraPython3Packages = ps: with ps; [simple-websocket-server python-slugify];
      };
    };
  };
}
