{
  description = "Development environment";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          go
        ];
      };

      packages.fnotify = pkgs.buildGoModule {
        pname = "fnotify";
        version = "0.1.0";
        src = self;
        vendorHash = null;

        meta = {
          description = "A file system notification tool";
          maintainers = with pkgs.lib.maintainers; [filipforsstrom];
        };
      };

      defaultPackage = self.packages.${system}.fnotify;

      nixosModules.default = {
        imports = [./fnotify.nix];

        config = {
          config,
          pkgs,
          ...
        }: {
          services.fnotify.package = self.packages.${system}.fnotify;
        };
      };
    });
}
