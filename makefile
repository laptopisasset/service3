SHELL := /bin/bash

# =========================================================================
# Testing running service

# expvarmon -ports=":4000" -vars="build,requests,goroutines,errors,panics,mem:memstats.Alloc"
# hey -m GET -c 100 -n 1000 http://localhost:3000/v1/test


# To generate a private/public key PEM file.
# openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
# openssl rsa -pubout -in private.pem -out public.pem


# ========================================================================

run:
	go run app/services/sales-api/main.go | go run app/tooling/logfmt/main.go

admin:
	go run app/tooling/admin/main.go

# ==============================================================================
# Modules support

tidy:
	go mod tidy
	go mod vendor


# ==============================================================================
# Building containers

# $(shell git rev-parse --short HEAD)
VERSION := 1.0

all: sales-api

sales-api:
	docker build \
		-f zarf/docker/dockerfile.sales-api \
		-t sales-api-arm64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.


# ==============================================================================
# Running from within k8s/kind

KIND_CLUSTER := sales-cluster

# Upgrade to latest Kind: brew upgrade kind
# For full Kind v0.13 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.13.0
# The image used below was copied by the above link and supports both amd64 and arm64.

kind-up:
	kind create cluster \
		--image kindest/node:v1.24.0@sha256:f68036a8c810306223c947fe047b873eef7f8b7a795f525d0b63fe62e263f78c \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=sales-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-load:
	cd zarf/k8s/kind/sales-pod; kustomize edit set image sales-api-image=sales-api-arm64:$(VERSION)
	kind load docker-image sales-api-arm64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/kind/sales-pod | kubectl apply -f -

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-logs:
	kubectl logs -l app=sales --all-containers=true -f --tail=100 | go run app/tooling/logfmt/main.go

kind-restart:
	kubectl rollout restart deployment sales-pod

kind-status-sales:
	kubectl get pods -o wide --watch

kind-update: all kind-load kind-restart

kind-update-apply: all kind-load kind-apply

kind-describe:
	kubectl describe pod -l app=sales