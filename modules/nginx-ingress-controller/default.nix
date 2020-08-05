{ pkgs, kpkgs, kubenix, config, ... }:

with pkgs.lib;

let
  yaml = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/baremetal/deploy.yaml";
    sha256 = "16ncnxbydvna4fl1drhvy983wx6q230c4khcclqj87bm5x88bsb5";
  };
  cfg = config.nginx-ingress-controller;
  resources = kpkgs.yaml2Resources yaml;

  applyCfg = cfg: resources:
    let
      resources' = if cfg.hostNetwork then recursiveUpdate resources { apps.v1.Deployment.ingress-nginx-controller.spec.template.spec.hostNetwork = true; } else resources;
      resources'' = recursiveUpdate resources { core.v1.Service.ingress-nginx-controller.spec.type = cfg.serviceType; };
    in
      resources'';
in
  {
    options.nginx-ingress-controller = {
      enable = mkEnableOption "nginx-ingress-controller";

      hostNetwork = mkOption {
        type = types.bool;
        default = false;
      };

      serviceType = mkOption {
        type = types.str;
        default = "NodePort";
      };
    };
    config = mkIf cfg.enable {
      kubernetes.resources = applyCfg cfg resources;
    };
  }
