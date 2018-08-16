local kp = (import 'nvidia-prometheus-exporter.libsonnet');

{ ['nvidia-exporter-' + name]: kp.nvidiaPrometheusExporter[name] for name in std.objectFields(kp.nvidiaPrometheusExporter) }