{pkgs, ...}: {
  # Wait for fox of either
  #  - https://github.com/nushell/nushell/issues/10826
  #  - https://github.com/nushell/nushell/issues/10963
  # xdg.configFile.nushell.source = ../nushell;
  home.packages = [
    pkgs.nushell
    pkgs.zoxide
  ];
}
