{ stdenv, lib, makeWrapper, gawk, slurm}:
stdenv.mkDerivation rec {
  pname = "jobs";
  version = "v0.0.1";

  src = ../../jobs;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a * $out/bin
    rm $out/bin/README.md
    wrapProgram "$out/bin/" --prefix PATH : "${
        lib.makeBinPath [
          awk
          slurm
        ]}"
  '';


  meta = with lib; {
    description = "Print Slurm nodes status with 1 line per node including job info.";
    homepage = "https://github.com/OleHolmNielsen/Slurm_tools";
    license = licenses.gpl3;
  };
}