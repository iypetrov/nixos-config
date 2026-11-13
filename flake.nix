{
  description = "Minimal NixOS config for a VMware Fusion aarch64 VM";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    system = "aarch64-linux";
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
  in {
    nixosConfigurations.vm-aarch64 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          home-manager.users.iypetrov = import ./users/iypetrov/home-manager.nix;
        }
      ];
    };
  };
}
