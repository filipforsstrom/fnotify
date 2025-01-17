{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule {
  pname = "fnotify";
  version = "0.1.0";

  src = ./.;

  vendorHash = null;

  meta = {
    description = "A file system notification tool";
    maintainers = with pkgs.lib.maintainers; [ filipforsstrom ];
  };
}
