{
  description = "Mato's ThinkCentre Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... } @ inputs: let
    system = "x86_64-linux";
  in {

    nixosConfigurations = {
      tc = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit inputs; };

        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
