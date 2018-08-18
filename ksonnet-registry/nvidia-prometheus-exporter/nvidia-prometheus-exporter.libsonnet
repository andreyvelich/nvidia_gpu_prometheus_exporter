{
  parts(params):: {
    all:: [
        $.parts(params).devicePluginDaemonset,
        $.parts(params).exporterDaemonset,
        $.parts(params).exporterService,
    ],

    devicePluginDaemonset: {
        apiVersion: "extensions/v1beta1",
        kind: "DaemonSet",
        metadata: {
            name: "nvidia-device-plugin-daemonset",
            namespace: "kube-system",
        },
        spec: {
            template: {
                metadata: {
                annotations: {
                    "scheduler.alpha.kubernetes.io/critical-pod": ""
                },
                labels: {
                    name: "nvidia-device-plugin-ds",
                    },
                },
                spec:{
                    tolerations: {
                        key: "CriticalAddonsOnly",
                        operator: "Exists",
                    },
                    containers: {
                        image: "nvidia/k8s-device-plugin:1.11",
                        name: "nvidia-device-plugin-ctr",
                        securityContext: {
                            allowPrivilegeEscalation: "false",
                            capabilities: {
                                drop: ["ALL"]
                            },
                        },
                        volumeMounts:{
                            name: "device-plugin",
                            mountPath: "/var/lib/kubelet/device-plugins",
                        },
                    },
                    volumes: {
                        name: "device-plugin",
                        hostPath: {
                            path: "/var/lib/kubelet/device-plugins",
                        },
                    },
                },
            },
        },
    }, //devicePluginDaemonset

    exporterDaemonset: {
        apiVersion: "extensions/v1beta1",
        kind: "DaemonSet",
        metadata: {
            name: "nvidia-gpu-exporter",
            namespace: params.namespace,
        },
        labels: {
            app: "prometheus",
            component: "nvidia-gpu-exporter",
        },
        spec: {
            template: {
                metadata: {
                    name: "nvidia-gpu-exporter",
                    labels: {
                        app: "prometheus",
                        component: "gpu-exporter",
                        },
                },
                spec: {
                    containers: {
                        image: "swiftdiaries/gpu_prom_metrics:latest",
                    name: "nvidia-gpu-exporter",
                    ports: {
                        name: "prom-gpu-exp",
                        containerPort: "9445",
                        hostPort: "9445",
                    },
                    hostNetwork: "true",
                    },
                },
            },
        },
    }, //exporterDaemonset

    exporterService: {
        apiVersion: "v1",
        kind: "Service",
        metadata: {
            annotations: {
                "prometheus.io/scrape": 'true'
                },
            name: "nvidia-gpu-exporter",
            namespace: params.namespace,
            labels: {
                app: "prometheus",
                component: "node-exporter"
                },
        },
        spec: {
            ports: [
                {
                name: "nvidia-gpu-exporter",
                port: "9445",
                protocol: "TCP",
                },
            ],
            selector: {
                app: "prometheus",
                component: "gpu-exporter",
            },
            type: "NodePort",
        },
    }, //exporterService,
},
}
