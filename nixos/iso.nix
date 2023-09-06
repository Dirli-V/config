# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.
{
  config,
  pkgs,
  ...
}: {
  # imports = [
  #   <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
  #
  #   # Provide an initial copy of the NixOS channel so that the user
  #   # doesn't need to run "nix-channel --update" first.
  #   # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  # ];

  services.openssh = {
    enable = false;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  users.users.root = {
    initialHashedPassword = "$6$.shBNnPjDhgc8eo7$YUIVi4uXcrkQ0PHLUvVAK91XZ/xIOUe3sd2r1AadNBxuUEkuQ8y5.ULy0pogZFea9S/19hkBrSPtQ.lEHy/v30";
  };
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialHashedPassword = "$6$.shBNnPjDhgc8eo7$YUIVi4uXcrkQ0PHLUvVAK91XZ/xIOUe3sd2r1AadNBxuUEkuQ8y5.ULy0pogZFea9S/19hkBrSPtQ.lEHy/v30";
  };

  system.stateVersion = "22.11";
}
