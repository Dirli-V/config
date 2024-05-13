{
  description = "NixOS Configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
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
      url = "github:Dirli-V/scape";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    };
    nixosModules = {
      neovim = ./neovim.nix;
      alacritty = ./alacritty.nix;
      nushell = ./nushell.nix;
      starship = ./starship.nix;
      wezterm = ./wezterm.nix;
      k9s = ./k9s.nix;
      btop = ./btop.nix;
      dev-tools = ./dev-tools.nix;
      ideavim = ./ideavim.nix;
      eww = ./eww.nix;
    };
    homeManagerModules = {
      default = ./default.nix;
    };
  };

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://scape.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "scape.cachix.org-1:DZrM365gcuH03W14BWTau3JjfbS+EomverT+ppifYDE="
    ];
  };
}
