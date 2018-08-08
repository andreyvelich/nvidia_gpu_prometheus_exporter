FROM golang:1.10 as builder

# Download and install the latest release of dep
ADD https://github.com/golang/dep/releases/download/v0.4.1/dep-linux-amd64 /usr/bin/dep
RUN chmod +x /usr/bin/dep

# Copy the code from the host and compile it
WORKDIR $GOPATH/src/github.com/mindprince/nvidia_gpu_prometheus_exporter
COPY Gopkg.toml Gopkg.lock ./
RUN dep ensure --vendor-only
COPY . ./
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o gpu_prometheus_exporter .

FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04  
WORKDIR /app
COPY --from=builder /go/src/github.com/mindprince/nvidia_gpu_prometheus_exporter/gpu_prometheus_exporter /app
EXPOSE 9445
RUN ls /app
CMD ["/app/gpu_prometheus_exporter"]
