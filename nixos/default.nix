{wired-notify, ...}: {
  imports = [
    ./alacritty.nix
    ./dev-tools.nix
    ./eww.nix
    ./helix.nix
    ./ideavim.nix
    ./k9s.nix
    ./neovim.nix
    ./nushell.nix
    ./scape.nix
    ./starship.nix
    ./wezterm.nix
    (import ./wired-notify.nix wired-notify)
  ];
}
