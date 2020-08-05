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
  configuration = {config, ...}: {
    imports = [
      kubenix.modules.k8s
      ./modules/nginx-ingress-controller
    ];
    nginx-ingress-controller = {
      enable = true;
      serviceType = "LoadBalancer";
    };
  };

  eval = (kubenix.evalModules {
    specialArgs = {
      inherit kubenix pkgs kpkgs;
    };
    modules = [ configuration ];
  });
in
  eval.config.kubernetes.result
