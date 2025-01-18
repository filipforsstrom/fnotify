{
  description = "fnotify";

  inputs = {
    # 1.23.2 release
    go-nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    go-nixpkgs,
    flake-utils,
  }: let
    nixosModule = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.services.fnotify = {
        enable = lib.mkEnableOption "fnotify";
        dir = lib.mkOption {
          type = lib.types.str;
          default = "/dev";
          description = "Directory to watch";
        };
        prefix = lib.mkOption {
          type = lib.types.str;
          default = "tty";
          description = "Comma-separated list of prefixes";
        };
        event = lib.mkOption {
          type = lib.types.str;
          default = "chmod,create,remove,rename,write";
          description = "Comma-separated list of events";
        };
      };

      config = lib.mkIf config.services.fnotify.enable {
        systemd.services.fnotify = {
          description = "fnotify";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          serviceConfig = {
            ExecStart = "${self.packages.${pkgs.system}.default}/bin/fnotify -dir=${config.services.fnotify.dir} -prefix=${config.services.fnotify.prefix} -event=${config.services.fnotify.event}";
            Restart = "always";
            Type = "simple";
            User = "ff";
          };
        };
      };
    };
  in
    (flake-utils.lib.eachDefaultSystem (system: let
      gopkg = go-nixpkgs.legacyPackages.${system};
    in {
      packages.default = gopkg.buildGoModule {
        pname = "fnotify";
        version = "0.1.0";
        src = ./.;
        vendorHash = null;
      };

      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/fnotify";
      };

      devShell = gopkg.mkShell {
        buildInputs = with gopkg; [go];
      };
    }))
    // {
      nixosModules.default = nixosModule;
    };
}
