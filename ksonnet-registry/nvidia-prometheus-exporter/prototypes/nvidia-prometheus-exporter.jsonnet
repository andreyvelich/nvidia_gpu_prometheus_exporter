// @apiVersion 0.1
// @name io.ksonnet.pkg.nvidia-prometheus-exporter
// @description A GPU stats exporter for Prometheus on Kubeflow.
// @shortDescription A Prometheus exporter.
// @param name string Name
// @optionalParam namespace string null Namespace to use for the components. It is automatically inherited from the environment if not set.

local k = import "k.libsonnet";

// updatedParams uses the environment namespace if
// the namespace parameter is not explicitly set
local updatedParams = params {
  namespace: if params.namespace == "null" then env.namespace else params.namespace,
};

local nvidiaGpuExporter = import "ksonnet-registry/nvidia-prometheus-exporter/nvidia-prometheus-exporter.libsonnet";
std.prune(k.core.v1.list.new(nvidiaGpuExporter.parts(updatedParams).all))