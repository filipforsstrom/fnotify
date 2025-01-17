{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.fnotify;
in {
  options = {
    services.fnotify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the fnotify service.";
      };

      dir = mkOption {
        type = types.str;
        default = "/dev";
        description = "Directory to watch.";
      };

      prefix = mkOption {
        type = types.str;
        default = "tty";
        description = "Prefix for files to watch.";
      };

      events = mkOption {
        type = types.str;
        default = "chmod,create,remove,rename,write";
        description = "Comma-separated list of events to watch.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.fnotify;
        description = "The fnotify package to use.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.fnotify = {
      description = "Fnotify Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/fnotify --dir ${cfg.dir} --prefix ${cfg.prefix} --event ${cfg.events}";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
