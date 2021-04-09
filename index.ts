import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

new k8s.yaml.ConfigFile("cert-manager", {
    file: "./deps/cert-manager/cert-manager.yaml",
});

const appLabels = { app: "nginx" };
const deployment = new k8s.apps.v1.Deployment("nginx", {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: { containers: [{ name: "nginx", image: "nginx" }] }
        }
    }
});
export const name = deployment.metadata.name;
