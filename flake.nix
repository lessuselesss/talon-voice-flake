{
  description = "Talon packaged for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

    outputs = { self, nixpkgs }:
      let
        # Define the supported systems
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
        
        # Helper function to create system-specific packages
        forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        });
      in 
      {
        packages = forAllSystems ({ pkgs }: {
          talon = pkgs.callPackage ./talon.nix {};
        });
      };
}
