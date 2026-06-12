{
  description = "NixOS Configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    scape = {
      url = "github:scape-wm/scape/323397065beb2cdc3db765799c1e33ec7fd2d1df";
      # Use the nixpkgs from scape to ensure that the cache has the needed files
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./parts/home-manager.nix
        ./parts/dev-shells.nix
      ];
      systems = [ "x86_64-linux" ];
    };
}
