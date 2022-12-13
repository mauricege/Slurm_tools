{ stdenv, lib, makeWrapper, gawk, slurm, }:
stdenv.mkDerivation rec {
  pname = "slurmreport";
  version = "v0.0.1";
  name = "slurmreport";

  src = ../../slurmreportmonth;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a slurmreportmonth $out/bin/slurmreport
    wrapProgram "$out/bin/slurmreport" --prefix PATH : "${
        lib.makeBinPath [
          gawk
          slurm
        ]}"
  '';


  meta = with lib; {
    description = "Slurm node and batch job status";
    homepage = "https://github.com/OleHolmNielsen/Slurm_tools";
    license = licenses.gpl3;
  };
}