{
  description = "NixOS Configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops.url = "github:Mic92/sops-nix";
    sops.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    disko,
    sops,
    ...
  } @ inputs: {
    nixosConfigurations = {
      dirli-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./desktop.nix];
      };
      dirli-surface = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./surface.nix];
      };
      nas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          disko.nixosModules.disko
          sops.nixosModules.sops
          ./nas-disk-config.nix
          ./nas.nix
        ];
      };
    };
    nixosModules = {
      neovim = ./neovim.nix;
      alacritty = ./alacritty.nix;
      nushell = ./nushell.nix;
      helix = ./helix.nix;
      starship = ./starship.nix;
      wezterm = ./wezterm.nix;
      k9s = ./k9s.nix;
      btop = ./btop.nix;
      dev-tools = ./dev-tools.nix;
      ideavim = ./ideavim.nix;
      eww = ./eww.nix;
    };
  };
}
