{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.slurmusersettings;
  groupOpts = {...}: {
    options = {
      parent = mkOption {
        type = types.str;
        description = "The user group's parent.";
      };
      fairshare = mkOption {
        type = types.int;
        default = 1;
        description = "The user group's fairshare value.";
      };
      # fairshare/GrpTRES/GrpTRESRunMins/QOS/DefaultQOS/MaxJobs/MaxSubmitJobs/MaxJobsAccrue/GrpJobsAccrue
      GrpTRES = mkOption {
        type = types.str;
        default = "";
        description = "GrpTRES string.";
      };
      GrpTRESRunMins = mkOption {
        type = types.str;
        default = "";
        description = "GrpTRESRunMins string.";
      };
      QOS = mkOption {
        type = types.str;
        default = "normal";
        description = "QOS string";
      };
      DefaultQOS = mkOption {
        type = types.str;
        default = "normal";
        description = "DefaultQOS string";
      };
      description = mkOption {
        type = types.str;
        default = "";
        description = "Description for the group.";
      };
    };
  };
  groupToAccountConf = name: options: ''
    ${name}:${options.parent}:${toString options.fairshare}:${options.description}
  '';
  groupToUserConf = name: options: ''
    ${name}:fairshare:${toString options.fairshare}
    ${name}:GrpTRES:${options.GrpTRES}
    ${name}:GrpTRESRunMins:${options.GrpTRESRunMins}
    ${name}:QOS:${options.QOS}
    ${name}:DefaultQOS:${options.DefaultQOS}
  '';
  defaultToUserConf = options: ''
    DEFAULT:fairshare:${toString options.fairshare}
    DEFAULT:GrpTRES:${options.GrpTRES}
    DEFAULT:GrpTRESRunMins:${options.GrpTRESRunMins}
    DEFAULT:QOS:${options.QOS}
    DEFAULT:DefaultQOS:${options.DefaultQOS}
  '';
  doNotCreateUserString = user: "NEWUSER:${user}:dontcreate";
  doNotCreateUsers = concatStringsSep "\n" (map doNotCreateUserString cfg.dontCreate);
  accountConfFile = with builtins;
    pkgs.writeTextDir "accounts.conf" ''
      ###
      ### Slurm accounts for cluster eihw-compute
      ###
      ### Syntax of the file is:
      ### account:parent:FairShare:Description
      ${(concatStringsSep "\n" (attrValues (mapAttrs groupToAccountConf cfg.groups)))}
    '';
  userConfFile = with builtins;
    pkgs.writeTextDir "user_settings.conf"
    ''
      #
      # This file defines *user* fairshare and limit values for UNIX groups or usernames.
      # Use this to assign values to all users within a UNIX primary group.
      # Specific usernames may also be configured to override the default or group values.
      #

      #
      # List syntax (fields are separated by ":"):
      #
      # [DEFAULT/UNIX_group/username]:[Type]:value
      #
      # Type examples: fairshare/GrpTRES/GrpTRESRunMins/QOS/DefaultQOS/MaxJobs/MaxSubmitJobs/MaxJobsAccrue/GrpJobsAccrue
      # Default settings for users without mapped UNIX group
      ${defaultToUserConf cfg.default}

      # Settings for users with mapped accounts
      ${(concatStringsSep "\n\n" (attrValues (mapAttrs groupToUserConf cfg.groups)))}

      # Do not create accounts for these users
      ${doNotCreateUsers}
    '';
in {
  options = {
    services.slurmusersettings = {
      enable = mkEnableOption "slurmusersettings service";
      autoUpdate = mkOption {
        type = types.bool;
        default = false;
      };
      groups = mkOption {
        type = types.attrsOf (types.submodule groupOpts);
        default = {};
        example = {
          DEFAULT = {fairshare = 1;};
        };
        description = ''
          User groups and their corresponding limits.
        '';
      };
      default = mkOption {
        type = removeAttrs (types.submodule groupOpts) ["parent"];
        default = {};
        description = ''
          Default slurm settings for users without mapped group.
        '';
      };
      dontCreate = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Do not create slurm accounts for these unix users.";
      };
    };
  };

  config = let
    wrappedUpdateAccounts = pkgs.writeShellScriptBin "updateslurmaccounts" ''
      exec env SLURM_CONF=${config.services.slurm.etcSlurm}/slurm.conf env SLURM_USER_SETTINGS=${config.services.slurm.etcSlurm}/user_settings.conf env SLURM_ACCOUNT_SETTINGS=${config.services.slurm.etcSlurm}/accounts.conf ${pkgs.slurm-tools.updateslurmaccounts}/bin/updateslurmaccounts $@
    '';
  in
    mkIf cfg.enable (
      mkMerge [
        {
          environment.systemPackages = [
            wrappedUpdateAccounts
          ];
          services.slurm.extraConfigPaths = [accountConfFile userConfFile];
        }
        (mkIf cfg.autoUpdate {
          systemd.services = {
            update-slurmaccounts = {
              description = "Automatically update slurmaccounts for system-level users.";
              requires = ["slurmdbd.service" "nslcd.service"];
              after = ["slurmdbd.service" "nslcd.service"];
              wantedBy = ["multi-user.target"];
              script = "${wrappedUpdateAccounts}/bin/updateslurmaccounts -y";
              path = with pkgs; [nss_pam_ldapd glibc];
            };
            # updateslurmaccounts.text = ''
            #   ${wrappedUpdateAccounts}/bin/updateslurmaccounts -n
            # '';
          };
        })
      ]
    );
}
