inputs: system: let
  inherit (inputs) astal;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
  astal.lib.mkLuaPackage {
    inherit pkgs;
    name = "astal-app";
    src = ./.;

    extraPackages = [
      astal.packages.${system}.tray
      astal.packages.${system}.wireplumber
      astal.packages.${system}.notifd
    ];
  }
