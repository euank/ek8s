import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

const kubeCertManager = new k8s.helm.v3.Chart("cert-manager", {
    path: "./deps/cert-manager/deploy/charts/cert-manager",
    values: {},
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
