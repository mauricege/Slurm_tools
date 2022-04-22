{ stdenv, lib, makeWrapper, gawk, slurm}:
stdenv.mkDerivation rec {
  pname = "showuserlimits";
  version = "v0.0.1";

  src = ../../showuserlimits;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a showuserlimits $out/bin
    wrapProgram "$out/bin/showuserlimits" --prefix PATH : "${
        lib.makeBinPath [
          awk
          slurm
        ]}"
  '';


  meta = with lib; {
    description = "Print Slurm resource user limits and usage";
    homepage = "https://github.com/OleHolmNielsen/Slurm_tools";
    license = licenses.gpl3;
  };
}