{ stdenv, lib, makeWrapper, gawk, slurm}:
stdenv.mkDerivation rec {
  pname = "slurmusersettings";
  version = "v0.0.1";

  src = ../../slurmaccounts;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a slurmusersettings $out/bin
    wrapProgram "$out/bin/slurmusersettings" --prefix PATH : "${
        lib.makeBinPath [
          gawk
          slurm
        ]}"
  '';


  meta = with lib; {
    description = "Sync slurm account to Unix groups.";
    homepage = "https://github.com/OleHolmNielsen/Slurm_tools";
    license = licenses.gpl3;
  };
}