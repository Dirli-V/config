{ags, ...}: {
  imports = [
    (import ./ags.nix ags)
    ./alacritty.nix
    ./dev-tools.nix
    ./helix.nix
    ./ideavim.nix
    ./k9s.nix
    ./neovim.nix
    ./nushell.nix
    ./scape.nix
    ./starship.nix
    ./wezterm.nix
  ];
}
