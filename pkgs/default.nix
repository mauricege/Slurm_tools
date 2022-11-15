final: prev: {
  slurm-tools = rec {
    pestat = prev.callPackage ./pestat {};
    showuserlimits = prev.callPackage ./showuserlimits {};
    showuserjobs = prev.callPackage ./showuserjobs {};
    slurmreport = prev.callPackage ./slurmreport {};
    slurmusersettings = prev.callPackage ./slurmusersettings {};
    slurmaccounts = prev.callPackage ./slurmaccounts {};
    updateslurmaccounts = prev.callPackage ./updateslurmaccounts { inherit slurmusersettings; };
  };
}