local k = import 'ksonnet.beta.3/k.libsonnet';

{
    nvidiaPrometheusExporter+:: {
        exporterDaemonset:
        local daemonset = k.extensions.v1beta1.daemonSet;
        local container = daemonset.mixin.spec.template.spec.containersType;
        local containerPort = container.portsType;
        local gpuExporter = container.new('nvidia-gpu-exporter', 'swiftdiaries/gpu_prom_metrics:latest') +
        container.withPorts(containerPort.withName('prom-gpu-exp') + containerPort.withContainerPort(9445) + containerPort.withHostPort(9445));
        daemonset.new() +
        daemonset.mixin.metadata.withName('nvidia-gpu-exporter') +
        daemonset.mixin.metadata.withNamespace('monitoring') +
        daemonset.mixin.metadata.withLabels({'app':'prometheus', 'component':'nvidia-gpu-exporter'}) +
        daemonset.mixin.spec.template.metadata.withName('nvidia-gpu-exporter') +
        daemonset.mixin.spec.template.metadata.withLabels({'app': 'prometheus', 'component': 'gpu-exporter'}) +
        daemonset.mixin.spec.template.spec.withContainers(gpuExporter) +
        daemonset.mixin.spec.template.spec.securityContext.withRunAsUser(0) +
        daemonset.mixin.spec.template.spec.securityContext.withRunAsNonRoot(false) +
        daemonset.mixin.spec.template.spec.withHostNetwork(true),

        devicePluginDaemonset:
        local daemonset = k.extensions.v1beta1.daemonSet;
        local container = daemonset.mixin.spec.template.spec.containersType;
        local containerPort = container.portsType;
        local tolerations = daemonset.mixin.spec.template.spec.tolerationsType;
        local gpuTolerations = tolerations.new() +
                               tolerations.withKey('CriticalAddonsOnly') +
                               tolerations.withOperator('Exists');
        
        local gpuVolumeName = 'device-plugin';
        local gpuVolumeType = daemonset.mixin.spec.template.spec.volumesType;
        local gpuVolumeMountType = container.volumeMountsType;
        local gpuVolume = gpuVolumeType.fromHostPath(gpuVolumeName, '/var/lib/kubelet/device-plugins');
        local gpuVolumeMount = gpuVolumeMountType.new(gpuVolumeName, '/var/lib/kubelet/device-plugins');

        local gpuDaemonsetContainer = container.new('nvidia-device-plugin-ctr', 'nvidia/k8s-device-plugin:1.11') +
        container.withVolumeMounts(gpuVolumeMount);

        daemonset.new() +
        daemonset.mixin.metadata.withName('nvidia-device-plugin-daemonset') +
        daemonset.mixin.metadata.withNamespace('kube-system') +
        daemonset.mixin.metadata.withAnnotations({'scheduler.alpha.kubernetes.io/critical-pod': ""}) +
        daemonset.mixin.metadata.withLabels({'name': 'nvidia-device-plugin-ds'}) +
        daemonset.mixin.spec.template.spec.withTolerations(gpuTolerations) +
        daemonset.mixin.spec.template.spec.withContainers(gpuDaemonsetContainer) +
        daemonset.mixin.spec.template.spec.securityContext.withRunAsUser(0) +
        daemonset.mixin.spec.template.spec.securityContext.withRunAsNonRoot(false) +
        daemonset.mixin.spec.template.spec.withVolumes([gpuVolume]),

        service:
        local service = k.core.v1.service;
        local servicePort = k.core.v1.service.mixin.specType.portsType;
        local exporterPort = servicePort.newNamed('nvidia-gpu-exporter', 9445, 9445);
        local portProtocol = servicePort.withProtocol('tcp');

        service.new('nvidia-gpu-exporter', {'component': 'gpu-exporter'}, exporterPort) +
        service.mixin.spec.withSelector({'app':'prometheus'}) +
        service.mixin.metadata.withAnnotations({'prometheus.io/scrape': 'true'}) +
        service.mixin.metadata.withNamespace('monitoring') +
        service.mixin.metadata.withLabels({'app': 'monitoring'}) +
        service.mixin.metadata.withLabels({'component': 'node-exporter'}) +
        service.mixin.spec.withType('NodePort'),

    },
}