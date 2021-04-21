{ pkgs, kpkgs, kubenix, config, ... }:

with pkgs.lib;

let
  cfg = config.euircbot;
in
{
  options.euircbot = {
    enable = mkEnableOption "euircbot";

    namespace = mkOption {
      type = types.str;
      default = "default";
    };

    config = mkOption {
      type = types.attrs;
      description = "config.json for the bot, but as an attr set";
    };

    moduleConfig = mkOption {
      type = types.attrs;
      description = "set of moduleConfig files";
    };

    dataVolume = mkOption {
      type = types.attrs;
      default = { emptyDir = {}; };
      description = "Volume type for persistent bot data. See https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core";
    };
  };
  config = mkIf cfg.enable {

    kubernetes.resources.core.v1.ConfigMap.euircbot = {
      data = {
        "config.json" = builtins.toJSON ({
          userName = "seubot";
          realName = "seubot";
          commandPrefix = "!";
          channels = [];
          autoRejoin = true;
          showErrors = true;
          channelPrefixes = "&#";
          messageSplit =  512;
          moduleFolders = ["modules"];
          datafolder = "data";
          tmpfolder = "tmp";
          configfolder = "conf";
        } // cfg.config);
      };
    };

    kubernetes.resources.core.v1.ConfigMap.euircbot-modules = {
      data = mapAttrs (k: v: builtins.toJSON v) cfg.moduleConfig;
    };

    # Statefulset rather than a deployment so only one is running at a time,
    # which is a handy guarantee for irc to avoid duplicate nicks / logs / etc
    kubernetes.resources.apps.v1.StatefulSet.euircbot = {
      spec = {
        replicas = 1;
        selector = {
          matchLabels = {
            app = "euircbot";
          };
        };
        serviceName = "euircbot";
        template = {
          metadata = {
            labels = {
              app = "euircbot";
            };
          };
          spec = {
            containers = [
              {
                name = "euircbot";
                # TODO: XXX
                image = "quay.io/euank/euircbot:latest";
                resources = {
                  requests = { memory = "600Mi"; };
                  limits = { memory = "800Mi"; };
                };
                volumeMounts = [
                  {
                    name = "module-config";
                    mountPath = "/usr/src/app/conf";
                  }
                  {
                    name = "data";
                    mountPath = "/usr/src/app/data";
                  }
                  {
                    name = "config";
                    mountPath = "/usr/src/app/config.json";
                    # TODO: subPath is awful, make it so the bot loads from a
                    # directory, not the file config.json
                    subPath = "config.json";
                  }
                ];
              }
            ];
            volumes = [
              {
                name = "module-config";
                configMap = { name = "euircbot-modules"; };
              }
              {
                name = "config";
                configMap = { name = "euircbot"; };
              }
              ({
                name = "data";
              } // cfg.dataVolume)
            ];
          };
        };
      };
    };
  };
}
