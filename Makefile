IMG = swiftdiaries/gpu_prom_metrics
TAG := $(shell date +v%Y%m%d)-$(GIT_VERSION)

all: build

build:
	docker build -f Dockerfile -t ${IMG}:${TAG} .
	docker tag ${IMG}:${TAG} ${IMG}:latest

push:
	docker push ${IMG}:${TAG}

push-latest:
	docker push ${IMG}:latest
