{ lib, stdenv, fetchzip, steam-run, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "talon";
  version = "0.3.1";
  
  src = fetchzip {
    url = "https://talonvoice.com/dl/latest/talon-linux.tar.xz";
    sha256 = "sha256-j3D2Tzlm+au6E8Y+XLAMPnGFk9zUz3znjjeAzY7AIHU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  
  dontBuild = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -a * $out
  '';

  fixupPhase = ''
    sed -i '4,8d' $out/run.sh
    makeWrapper ${steam-run}/bin/steam-run $out/bin/talon --add-flags $out/run.sh 
  '';
  
  meta = with lib; {
    description = "Talon voice control system";
    platforms = platforms.linux;
    maintainers = with maintainers; [ polygon ];
  };
}
