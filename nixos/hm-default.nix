{
  astal,
  scape,
  ...
}: {
  imports = [
    (import ./astal.nix astal)
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
