{ inputs, ... }: {
  flake.homeManagerModules = {
    default = import ../nixos/hm-default.nix inputs;
  };
}
