{
  lib,
  pkgs,
  config,
  ...
}: let
  intellij-server = pkgs.callPackage ../pkgs/intellij-server.nix {};
in {
  options.shared-config.neovim.enable = lib.mkEnableOption "Enable shared neovim config";

  config = lib.mkIf config.shared-config.neovim.enable {
    xdg.configFile.nvim.source = ../nvim;
    home.packages =
      with pkgs; [
        ripgrep
        tree-sitter
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
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
        intellij-server
        jdk25
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
