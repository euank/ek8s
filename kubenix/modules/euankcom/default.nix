{ pkgs, kpkgs, kubenix, config, ... }:

with pkgs.lib;

let
  cfg = config.euankcom;
in
{
  options.euankcom = {
    enable = mkEnableOption "euankcom";

    image = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    kubernetes.resources.deployments.euank-com = {
      metadata = { name = "euank-com"; };
      spec = {
        replicas = 3;
        selector.matchLabels = { app = "euank-com"; name = "euank-com"; };
        template = {
          metadata = { labels = { app = "euank-com"; name = "euank-com"; }; };
          spec = {
            containers = [{
              name = "web";
              image = cfg.image;
              resources = { limits = { memory = "100Mi"; }; };
              ports = [{ name = "http"; containerPort = 8080; }];
            }];
            imagePullSecrets = [{name = "ecr";}];
          };
        };
      };
    };

    kubernetes.resources.core.v1.Service.euank-com = {
      metadata = { name = "euank-com"; };
      spec = {
        type = "NodePort";
        selector = { app = "euank-com"; };
        ports = [{ name = "http"; port = 8080; targetPort = 8080; }];
      };
    };

    kubernetes.resources.ingresses.euank-com = {
      metadata = { name = "euank-com"; };
      spec = {
        tls = [{
          hosts = [ "euank.com" "www.euank.com" ];
          secretName = "euank-com-cert";
        }];
        rules = lists.map (host: {
          inherit host;
          http = {
            paths = [
              {
                path = "/";
                backend = {
                  serviceName = "euank-com";
                  servicePort = 8080;
                };
              }
            ];
          };
        }) [ "euank.com" "www.euank.com" ];
      };
    };
  };
}
