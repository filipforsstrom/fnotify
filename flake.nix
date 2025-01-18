{
  description = "fnotify";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          go
        ];
      };

      packages = {
        default = pkgs.buildGoModule {
          pname = "fnotify";
          version = "0.1.0";
          src = ./.;
          vendorHash = null;

          meta = {
            description = "A file system notification tool";
            maintainers = with pkgs.lib.maintainers; [filipforsstrom];
          };
        };
      };
    });
}
