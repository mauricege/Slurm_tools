{ stdenv, lib, makeWrapper, gawk, slurm}:
stdenv.mkDerivation rec {
  pname = "showuserjobs";
  version = "v0.0.1";

  src = ../../showuserjobs;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a showuserjobs $out/bin
    wrapProgram "$out/bin/showuserjobs" --prefix PATH : "${
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