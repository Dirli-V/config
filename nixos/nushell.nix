{
  pkgs,
  config,
  ...
}: {
  xdg.configFile = {
    # this can probably be done better, but the history file makes it awkward
    "nushell/history.txt".source = config.lib.file.mkOutOfStoreSymlink "/home/dirli/.local/share/nushell/history.txt";
    "nushell/atuin.nu".source = ../nushell/atuin.nu;
    "nushell/bluetooth.nu".source = ../nushell/bluetooth.nu;
    "nushell/cargo.nu".source = ../nushell/cargo.nu;
    "nushell/cerebro.nu".source = ../nushell/cerebro.nu;
    "nushell/config.nu".source = ../nushell/config.nu;
    "nushell/env.nu".source = ../nushell/env.nu;
    "nushell/git.nu".source = ../nushell/git.nu;
    "nushell/killall.nu".source = ../nushell/killall.nu;
    "nushell/nix.nu".source = ../nushell/nix.nu;
    "nushell/paru.nu".source = ../nushell/paru.nu;
    "nushell/systemd.nu".source = ../nushell/systemd.nu;
    "nushell/venv.nu".source = ../nushell/venv.nu;
    "nushell/xplr.nu".source = ../nushell/xplr.nu;
    "nushell/zellij.nu".source = ../nushell/zellij.nu;
    "nushell/zoxide.nu".source = ../nushell/zoxide.nu;
    atuin.source = ../atuin;
  };
  home.packages = [
    pkgs.nushell
    pkgs.zoxide
    pkgs.atuin
  ];
}
