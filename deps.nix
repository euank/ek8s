let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4cb48cc25622334f17ec6b9bf56e83de0d521fb7.tar.gz";
    sha256 = "0z005p4jwlnfh9gbgjc3anzrabzdys2d94l4chvdhzxr1pyj4imy";
  }) {};
  cert-manager-yaml = pkgs.fetchurl {
    url = "https://github.com/jetstack/cert-manager/releases/download/v1.3.0/cert-manager.yaml";
    sha256 = "sha256-yqWcmXa2rIvjz+JVy51fvgWWTZuM27nm1s80MZloHTM=";
  };

  euircbot-yaml = import ./kubenix.nix { inherit pkgs; };
in
  pkgs.stdenv.mkDerivation {
    pname = "puk8s-deps";
    version = "0.0.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/cert-manager $out/euircbot
      ln -vsf ${cert-manager-yaml} $out/cert-manager/cert-manager.yaml
      ln -vsf ${euircbot-yaml} $out/euircbot/euircbot.yaml
    '';
  }
