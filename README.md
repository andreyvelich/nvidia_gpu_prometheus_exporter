NVIDIA GPU Prometheus Exporter
------------------------------

This is a [Prometheus Exporter](https://prometheus.io/docs/instrumenting/exporters/) for
exporting NVIDIA GPU metrics. It uses the [Go bindings](https://github.com/mindprince/gonvml)
for [NVIDIA Management Library](https://developer.nvidia.com/nvidia-management-library-nvml)
(NVML) which is a C-based API that can be used for monitoring NVIDIA GPU devices.
Unlike some other similar exporters, it does not call the
[`nvidia-smi`](https://developer.nvidia.com/nvidia-system-management-interface) binary.

## Design Doc

[[https://github.com/swiftdiaries/nvidia_gpu_prometheus_exporter/blob/master/gpu-design-doc.jpg|alt=designdoc]]

## Building

The repository includes `nvml.h`, so there are no special requirements from the
build environment. `go get` should be able to build the exporter binary.

```
go get github.com/mindprince/nvidia_gpu_prometheus_exporter
```

## Running on Kubernetes

```
kubectl create -f https://raw.githubusercontent.com/swiftdiaries/nvidia_gpu_prometheus_exporter/master/nvidia-exporter.yaml
```

## Complete setup on a k8s cluster

Note: Ensure nvidia-docker is installed.
###### Verify nvidia-docker
`$ sudo docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi`

Reference: [GitHub - NVIDIA/nvidia-docker: Build and run Docker containers leveraging NVIDIA GPUs](https://github.com/NVIDIA/nvidia-docker)

#### Nvidia driver install - daemonset
`$ kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.11/nvidia-device-plugin.yml`
Note: It takes a couple of minutes for the drivers to install.

#### Prometheus, Grafana install (uses complicated YAML ~ 2k lines, // TODO reconfigure)
`$ kubectl apply --filename https://raw.githubusercontent.com/giantswarm/kubernetes-prometheus/master/manifests-all.yaml` 

#### Grafana dashboard

`wget https://raw.githubusercontent.com/swiftdiaries/nvidia_gpu_prometheus_exporter/master/Prometheus-GPU-stats-1533769198014.json`

Import this JSON to Grafana.

#### Preview

![Grafana Preview](https://raw.githubusercontent.com/swiftdiaries/nvidia_gpu_prometheus_exporter/master/GPU-stats-grafana-screens.png "Grafana GPU stats")
Note: Excuse the flat duty cycle. 


## TODO

1. Reduce size of image used for exporter.
2. Simpler / manageable YAML for Prometheus. 
3. ksonnet app for easy deployments / integration with Kubeflow.

Note: priority is not necessarily in that order.



## Run locally using Docker

`$ make build`

`$ docker run -p 9445:9445 --rm --runtime=nvidia swiftdiaries/gpu_prom_metrics`

Make changes, build, iterate.

Verify:

`$ localhost:9445/metrics | grep -i "gpu"`

```
Sample output:

# HELP nvidia_gpu_duty_cycle Percent of time over the past sample period during which one or more kernels were executing on the GPU device
# TYPE nvidia_gpu_duty_cycle gauge
nvidia_gpu_duty_cycle{minor_number="0",name="GeForce GTX 950",uuid="GPU-6e7a0fa1-0770-c210-1a5c-8710bc09ce00"} 0
# HELP nvidia_gpu_fanspeed_percent Fanspeed of the GPU device as a percent of its maximum
# TYPE nvidia_gpu_fanspeed_percent gauge
nvidia_gpu_fanspeed_percent{minor_number="0",name="GeForce GTX 950",uuid="GPU-6e7a0fa1-0770-c210-1a5c-8710bc09ce00"} 0
# HELP nvidia_gpu_memory_total_bytes Total memory of the GPU device in bytes
# TYPE nvidia_gpu_memory_total_bytes gauge
nvidia_gpu_memory_total_bytes{minor_number="0",name="GeForce GTX 950",uuid="GPU-6e7a0fa1-0770-c210-1a5c-8710bc09ce00"} 2.092171264e+09
# HELP nvidia_gpu_memory_used_bytes Memory used by the GPU device in bytes
# TYPE nvidia_gpu_memory_used_bytes gauge
nvidia_gpu_memory_used_bytes{minor_number="0",name="GeForce GTX 950",uuid="GPU-6e7a0fa1-0770-c210-1a5c-8710bc09ce00"} 1.048576e+06
# HELP nvidia_gpu_num_devices Number of GPU devices
# TYPE nvidia_gpu_num_devices gauge
nvidia_gpu_num_devices 1
# HELP nvidia_gpu_power_usage_milliwatts Power usage of the GPU device in milliwatts
# TYPE nvidia_gpu_power_usage_milliwatts gauge
nvidia_gpu_power_usage_milliwatts{minor_number="0",name="GeForce GTX 950",uuid="GPU-6e7a0fa1-0770-c210-1a5c-8710bc09ce00"} 13240
# HELP nvidia_gpu_temperature_celsius Temperature of the GPU device in celsius
# TYPE nvidia_gpu_temperature_celsius gauge
nvidia_gpu_temperature_celsius{minor_number="0",name="GeForce GTX 950",uuid="GPU-6e7a0fa1-0770-c210-1a5c-8710bc09ce00"} 34
```

## Running locally pre-requisites

The exporter requires the following:
- access to NVML library (`libnvidia-ml.so.1`).
- access to the GPU devices.

To make sure that the exporter can access the NVML libraries, either add them
to the search path for shared libraries. Or set `LD_LIBRARY_PATH` to point to
their location.

By default the metrics are exposed on port `9445`. This can be updated using
the `-web.listen-address` flag.
