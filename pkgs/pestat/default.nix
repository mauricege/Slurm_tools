{ stdenv, lib, makeWrapper, gawk, slurm}:
stdenv.mkDerivation rec {
  pname = "pestat";
  version = "v0.0.1";

  src = ../../pestat;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a pestat $out/bin
    wrapProgram "$out/bin/pestat" --prefix PATH : "${
        lib.makeBinPath [
          gawk
          slurm
        ]}"
  '';


  meta = with lib; {
    description = "Print Slurm nodes status with 1 line per node including job info.";
    homepage = "https://github.com/OleHolmNielsen/Slurm_tools";
    license = licenses.gpl3;
  };
}