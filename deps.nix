let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4cb48cc25622334f17ec6b9bf56e83de0d521fb7.tar.gz";
    sha256 = "0z005p4jwlnfh9gbgjc3anzrabzdys2d94l4chvdhzxr1pyj4imy";
  }) {};
  cert-manager = fetchTarball {
    url = "https://github.com/jetstack/cert-manager/archive/refs/tags/v1.3.0.tar.gz";
    sha256 = "1rs32wh0g1hmhc804hdaf9wnrqgxkr24b4z84cwbl1zfmlgh1k0h";
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "puk8s-deps";
    version = "0.0.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out

      ln -vsf ${cert-manager} $out/cert-manager

    '';
  }
