{
  description = "Talon packaged for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

    outputs = { self, nixpkgs }:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          system = "x86_64-linux";
        };
      in 
      {
        packages.x86_64-linux.talon = pkgs.callPackage ./talon.nix {};
      };
}
