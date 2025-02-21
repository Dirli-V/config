{scape, ...} @ inputs: {
  imports = [
    (import ./astal.nix inputs)
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
