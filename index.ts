import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

const ecrCreds = new k8s.yaml.ConfigGroup("ecr-updater", {
    files: [ "./yaml/ecr-updater/01_authorization.yml", "./yaml/ecr-updater/02_deployment.yml" ],
});

const certManager = new k8s.yaml.ConfigFile("cert-manager", {
    file: "./deps/cert-manager/cert-manager.yaml",
});

const issuers = new k8s.yaml.ConfigGroup("cert-manager-issuers", {
    files: [
        "./yaml/cert-manager/issuers/staging.yml",
    ],
}, { dependsOn: [ certManager ]});

new k8s.yaml.ConfigFile("euircbot", {
    file: "./deps/euircbot/euircbot.yaml",
}, { dependsOn: [ ecrCreds, issuers ] });

