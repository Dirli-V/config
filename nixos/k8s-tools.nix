{
  lib,
  pkgs,
  config,
  ...
}: {
  options.shared-config.k8s-tools.enable = lib.mkEnableOption "Enable shared k8s-tools config";

  config = lib.mkIf config.shared-config.k8s-tools.enable {
    home.packages = with pkgs; [
      taplo
      bandwhich
      kubectl
      kubernetes-helm
      du-dust
      dive
    ];
  };
}
