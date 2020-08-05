{ pkgs, kpkgs, kubenix, ... }:
let
  yaml = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/baremetal/deploy.yaml";
    sha256 = "16ncnxbydvna4fl1drhvy983wx6q230c4khcclqj87bm5x88bsb5";
  };
in
  {
    imports = with kubenix.modules; [
      k8s
    ];

    kubernetes.resources = kpkgs.yaml2Resources yaml;
  }
