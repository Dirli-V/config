{
  lib,
  config,
  ...
}: {
  options.shared-config.ideavim.enable = lib.mkEnableOption "Enable shared ideavim config";

  config = lib.mkIf config.shared-config.ideavim.enable {
    home.file.".ideavimrc".source = ../.ideavimrc;
  };
}
