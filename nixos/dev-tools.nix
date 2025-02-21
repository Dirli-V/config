{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.dev-tools.enable = lib.mkEnableOption "Enable shared dev-tools config";

  config = lib.mkIf config.shared-config.dev-tools.enable {
    home.packages = with pkgs; [
      nodePackages.bash-language-server
      python3
      sumneko-lua-language-server
      stylua
      bandwhich
      du-dust
      p7zip
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
