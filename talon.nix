{ lib, stdenv, fetchzip, fetchurl, steam-run, makeWrapper, undmg }:

let
  # Define platform-specific values
  platformData = if stdenv.isDarwin then {
    url = "https://talonvoice.com/dl/latest/talon-mac.dmg";
    sha256 = "sha256-QC+LSsFy2XNg47YMN1PmUr2sxAj5K3lUf5bDThrLZ70=";
    fetcher = fetchurl;
  } else {
    url = "https://talonvoice.com/dl/latest/talon-linux.tar.xz";
    sha256 = "sha256-j3D2Tzlm+au6E8Y+XLAMPnGFk9zUz3znjjeAzY7AIHU=";
    fetcher = fetchzip;
  };
in
stdenv.mkDerivation rec {
  pname = "talon";
  version = "0.4.0";
  
  src = platformData.fetcher {
    inherit (platformData) url sha256;
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.isDarwin [ undmg ];
  
  dontBuild = true;
  dontPatchELF = true;

  unpackPhase = if stdenv.isDarwin then ''
    undmg $src
  '' else ''
    unpackPhase
  '';

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
