#!/usr/bin/env bash

# This script configures a local kind cluster with the calico networking stack
# and MetalLB providing the load balancing service.

set -e

# Create the cluster
echo ">>> Creating cluster..."
kind create cluster --config "${PRJ_ROOT}/scripts/manifests/kind.yml"

# Install Calico
echo ">>> Installing Calico..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Wait for calico
echo ">>> Waiting 60 seconds for Calico..."
sleep 60

# Install MetalLB
echo ">>> Installing MetalLB..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# Wait for MetalLB
echo ">>> Waiting for MetalLB to come up..."
kubectl wait --namespace metallb-system \
    --for=condition=ready pod \
    --selector=app=metallb \
    --timeout=180s

# Configure MetalLB
echo ">>> Configuring MetalLB..."
kubectl apply -f "${PRJ_ROOT}/scripts/manifests/metallb.yml"

echo ">>> Done!"
