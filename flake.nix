{
  description = "NixOS Configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    scape = {
      url = "github:scape-wm/scape/323397065beb2cdc3db765799c1e33ec7fd2d1df";
      # Use the nixpkgs from scape to ensure that the cache has the needed files
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
  in {
    homeManagerModules = {
      default = import ./nixos/hm-default.nix inputs;
    };

    packages.${system} = {
      astal = import ./astal/package.nix inputs system;
    };

    apps.${system} = {
      type = "app";
      program = "${inputs.self.packages.${system}.astal}/bin/astal-app";
    };

    devShells.${system} = {
      default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = [];
      };
    };
  };
}
