{
  description = "NixOS Configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    wired-notify = {
      url = "github:Toqozz/wired-notify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    scape = {
      url = "github:scape-wm/scape/323397065beb2cdc3db765799c1e33ec7fd2d1df";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations = {
      dirli-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./desktop.nix];
      };
      dirli-surface = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./surface.nix];
      };
      dirli-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./laptop.nix];
      };
    };
    nixosModules = {
      default = import ./nixos-default.nix inputs;
    };
    homeManagerModules = {
      default = import ./hm-default.nix inputs;
    };
  };
}
