{ stdenv, lib, makeWrapper, slurm, slurmusersettings, slurmaccounts }:
stdenv.mkDerivation rec {
  pname = "updateslurmaccounts";
  version = "v0.0.1";

  src = ../../slurmaccounts;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a updateslurmaccounts $out/bin
    wrapProgram "$out/bin/updateslurmaccounts" --prefix PATH : "${
        lib.makeBinPath [
          slurm
          slurmusersettings
          slurmaccounts
        ]}"
  '';


  meta = with lib; {
    description = "Sync slurm account to Unix groups.";
    homepage = "https://github.com/OleHolmNielsen/Slurm_tools";
    license = licenses.gpl3;
  };
}