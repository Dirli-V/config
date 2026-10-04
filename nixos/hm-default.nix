{
  scape,
  dms,
  ...
} @ inputs: {
  imports = [
    ./dev-tools.nix
    ./ai-tools.nix
    ./k8s-tools.nix
    ./nix-tools.nix
    ./sql-tools.nix
    ./rust-tools.nix
    ./helix.nix
    ./ideavim.nix
    ./k9s.nix
    ./neovim.nix
    ./nushell.nix
    (import ./scape.nix scape)
    (import ./dms.nix dms)
    ./lumalla-lanes.nix
    ./starship.nix
    ./wezterm.nix
  ];
}
