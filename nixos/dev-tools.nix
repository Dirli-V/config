{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.dev-tools.enable = lib.mkEnableOption "Enable shared dev-tools config";

  config = lib.mkIf config.shared-config.dev-tools.enable {
    home.packages = with pkgs; [
      nodejs
      nodePackages.cspell
      nodePackages.jsonlint
      nodePackages.stylelint
      nodePackages.vscode-json-languageserver
      nodePackages.fixjson
      nodePackages.bash-language-server
      ruff
      taplo
      ltex-ls
      nil
      alejandra
      deadnix
      statix
      python3
      python3Packages.autopep8
      python3Packages.debugpy
      luajitPackages.jsregexp
      sumneko-lua-language-server
      stylua
      fd
      xplr
      bandwhich
      kubectl
      kubernetes-helm
      proselint
      codespell
      inlyne
      du-dust
      p7zip
      mpv
      lm_sensors
    ];

    programs = {
      git = {
        enable = true;
        extraConfig = {
          core = {
            editor = "nvim";
          };
          push.autoSetupRemote = true;
          init.defaultBranch = "main";
        };
        difftastic = {
          enable = true;
        };
        lfs.enable = true;
      };

      fzf.enable = true;
    };
  };
}
