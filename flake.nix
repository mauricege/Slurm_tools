{
  description = "Nix packages and NixOS modules for Ole Holm Nielsen's Slurm tools.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    let
      inherit (nixpkgs) lib;
      name = "slurm-tools";
      overlay = final: prev: {
        inherit (overlayPackages prev prev) slurm-tools;
      };
      overlayPackages = import ./pkgs;
      shell = ./shell.nix;
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          p = inputs.nixpkgs.legacyPackages.${system};

          packages = (overlayPackages p p).slurm-tools;
        in
        {
          # Use the legacy packages since it's more forgiving.
          # inherit overlay;
          legacyPackages = packages;
          inherit packages;
        }
        //
        (
          if packages ? checks then {
            checks = packages.checks;
          } else { }
        )
        //
        {
          # devShell = import shell { pkgs = p.pkgs; };
        }
      ) //
    {
      inherit overlay;
      nixosModules = {
        slurmreports = import ./modules/services/slurmreports.nix;
      };
    };
}
