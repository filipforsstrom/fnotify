{
  description = "Basic Go web app";

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
        enable = lib.mkEnableOption "Basic Go web app service";
      };

      config = lib.mkIf config.services.fnotify.enable {
        systemd.services.fnotify = {
          description = "Basic Go Web App Service";
          wantedBy = ["multi-user.target"];
          after = ["graphical.target"];
          serviceConfig = {
            ExecStart = "${self.packages.${pkgs.system}.default}/bin/fnotify";
            Restart = "always";
            Type = "simple";
            DynamicUser = "yes";
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
    }))
    // {
      nixosModules.default = nixosModule;
    };
}
