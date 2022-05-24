SHELL := /bin/bash

run:
	go run main.go


# ==============================================================================
# Building containers

# $(shell git rev-parse --short HEAD)
VERSION := 1.0

all: service

service:
	docker build \
		-f zarf/docker/Dockerfile \
		-t service-arm64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# ==============================================================================
# Running from within k8s/kind

KIND_CLUSTER := service-cluster

# Upgrade to latest Kind: brew upgrade kind
# For full Kind v0.13 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.13.0
# The image used below was copied by the above link and supports both amd64 and arm64.

kind-up:
	kind create cluster \
		--image kindest/node:v1.18.20@sha256:13d4b6546e9ca635a572728942c49617fc41fa43df7c600607e6515c7e2398b9 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)


kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide