{ lib, config, pkgs, ... }: 1
with lib;
let
  cfg = config.services.slurmreport;

in {

  options = {
    services.slurmreport = {
      enable = mkEnableOption "slurmreport service";
      interval = mkOption {
        type = types.enum ["weekly" "monthly"];
        default = ["monthly"];
      };
      outputPath = mkOption {
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.slurmreport = {
     serviceConfig.Type = "oneshot";
      environment = {
        SLURM_CONF = config.services.slurm.etcSlurm;
      };
      script = ''
        ${pkgs.slurm-tools.slurmreport} ${if cfg.interval == "weekly" then "-w" else ""} -r ${cfg.outputPath}
      '';

    };
    systemd.timers.slurmreport = {
      description = "Run slurmreports periodically.";
      wantedBy = [ "timers.target" ]; # enable it & auto start it
      timerConfig = {
        OnCalendar = cfg.interval;
      };
    };
  };
}