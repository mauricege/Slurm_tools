final: prev: {
  slurm-tools = {
    pestat = prev.callPackage ./pestat {};
    showuserlimits = prev.callPackage ./showuserlimits {};
    showuserjobs = prev.callPackage ./showuserjobs {};
    slurmreport = prev.callPackage ./slurmreport {};
  };
}