import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

new k8s.yaml.ConfigFile("cert-manager", {
    file: "./deps/cert-manager/cert-manager.yaml",
});

new k8s.yaml.ConfigFile("euircbot", {
    file: "./deps/euircbot/euircbot.yaml",
});
