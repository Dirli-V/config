{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.nix-tools.enable = lib.mkEnableOption "Enable shared nix-tools config";

  config = lib.mkIf config.shared-config.nix-tools.enable {
    home.packages = with pkgs; [
      nixd
      alejandra
      deadnix
      statix
      nix-inspect
      nix-index
    ];
  };
}
