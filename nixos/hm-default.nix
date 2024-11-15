{
  ags,
  scape,
  ...
}: {
  imports = [
    (import ./ags.nix ags)
    ./alacritty.nix
    ./dev-tools.nix
    ./helix.nix
    ./ideavim.nix
    ./k9s.nix
    ./neovim.nix
    ./nushell.nix
    (import ./scape.nix scape)
    ./starship.nix
    ./wezterm.nix
  ];
}
