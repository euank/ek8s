{
  pkgs ? import <nixpkgs> {},
  kubenix ? import (pkgs.fetchgit {
    url = "https://github.com/xtruder/kubenix/";
    rev = "611059a329493a77ec0e862fcce4671cd3768f32";
    sha256 = "1lmmzb087ahmx2mdjarbi52a9424qczhzqbxrvcrg11cbmv9b191";
  }) {}
}:

let
  kpkgs = import ./kpkgs { inherit pkgs; };
  config = (kubenix.evalModules {
    specialArgs = {
      inherit kubenix pkgs kpkgs;
    };
    modules = [
      ./modules/nginx-ingress-controller
    ];
  }).config;
in
  config.kubernetes.result
