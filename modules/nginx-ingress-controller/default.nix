{ pkgs, kpkgs, kubenix, config, ... }:

with pkgs.lib;

let
  yaml = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/baremetal/deploy.yaml";
    sha256 = "16ncnxbydvna4fl1drhvy983wx6q230c4khcclqj87bm5x88bsb5";
  };
  cfg = config.nginx-ingress-controller;
  resources = kpkgs.yaml2Resources yaml;
in
  {
    options.nginx-ingress-controller = {
      enable = mkEnableOption "nginx-ingress-controller";

      hostNetwork = mkOption {
        type = types.bool;
        default = false;
      };
    };
    config = mkMerge [
      {
        kubernetes.resources = resources;
      }
      (mkIf cfg.hostNetwork {
        kubernetes.resources.apps.v1.Deployment.ingress-nginx-controller.spec.template.spec.hostNetwork = true;
      })
    ];
  }
