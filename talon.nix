{ lib, stdenv, fetchzip, steam-run, makeWrapper }:

let
  # Define platform-specific values
  platformData = if stdenv.isDarwin then {
    url = "https://talonvoice.com/dl/latest/talon-mac.dmg";
    sha256 = "sha256-1pfslw5nrfb7w153zckcafacz2vr8ymf5gh5mvb2gi22n0d2b4h4="; # You'll need to replace this with the actual hash
  } else {
    url = "https://talonvoice.com/dl/latest/talon-linux.tar.xz";
    sha256 = "sha256-j3D2Tzlm+au6E8Y+XLAMPnGFk9zUz3znjjeAzY7AIHU=";
  };
in
stdenv.mkDerivation rec {
  pname = "talon";
  version = "0.4.0";
  
  src = fetchzip (platformData // {
    inherit (platformData) url sha256;
  });

  nativeBuildInputs = [ makeWrapper ];
  
  dontBuild = true;
  dontPatchELF = true;

  installPhase = if stdenv.isDarwin then ''
    mkdir -p $out/Applications
    cp -a *.app $out/Applications/
    mkdir -p $out/bin
    makeWrapper "$out/Applications/Talon.app/Contents/MacOS/talon" "$out/bin/talon"
  '' else ''
    mkdir -p $out/bin
    cp -a * $out
  '';

  fixupPhase = if stdenv.isDarwin then "" else ''
    sed -i '4,8d' $out/run.sh
    makeWrapper ${steam-run}/bin/steam-run $out/bin/talon --add-flags $out/run.sh 
  '';
  
  meta = with lib; {
    description = "Talon voice control system";
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ lessuselesss ];
  };
}
