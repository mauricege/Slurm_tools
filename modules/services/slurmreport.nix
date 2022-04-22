{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.slurmreport;

in {

  options = {
    services.slurmreport = {
      enable = mkEnableOption "slurmreport service";
      intervals = mkOption {
        type = types.listOf (types.enum ["weekly" "monthly"]);
        default = ["monthly"];
      };
      outputPath = mkOption {
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      (mkIf (elem "monthly" cfg.intervals) {
        systemd.services.slurmreport-monthly = {
        serviceConfig.Type = "oneshot";
          environment = {
            SLURM_CONF = config.services.slurm.etcSlurm;
          };
          script = ''
            ${pkgs.slurm-tools.slurmreport}/bin/slurmreport -r ${cfg.outputPath}
          '';

        };
        systemd.timers.slurmreport-monthly = {
          description = "Run slurmreports periodically.";
          wantedBy = [ "timers.target" ]; # enable it & auto start it
          timerConfig = {
            OnCalendar = "monthly";
          };
        };
      })
      (mkIf (elem "weekly" cfg.intervals) {
        systemd.services.slurmreport-weekly = {
        serviceConfig.Type = "oneshot";
          environment = {
            SLURM_CONF = config.services.slurm.etcSlurm;
          };
          script = ''
            ${pkgs.slurm-tools.slurmreport}/bin/slurmreport -w -r ${cfg.outputPath}
          '';
        };
        systemd.timers.slurmreport-weekly = {
          description = "Run slurmreports periodically.";
          wantedBy = [ "timers.target" ]; # enable it & auto start it
          timerConfig = {
            OnCalendar = "weekly";
          };
        };
      })
    ]
  );
}