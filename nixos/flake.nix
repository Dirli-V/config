{
  description = "NixOS Configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    scape = {
      url = "github:scape-wm/scape/323397065beb2cdc3db765799c1e33ec7fd2d1df";
      # Use the nixpkgs from scape to ensure that the cache has the needed files
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    homeManagerModules = {
      default = import ./hm-default.nix inputs;
    };
  };
}
