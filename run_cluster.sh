#!/usr/bin/env bash
set -euo pipefail

echo "Starting Docker-in-Docker k3d bootstrap..."

# start dockerd (dind image has dockerd available)
# The dind image ENTRYPOINT usually already starts dockerd when container is run --privileged.
# But start explicitly if not running.
if ! pgrep dockerd >/dev/null 2>&1; then
  dockerd --host=unix:///var/run/docker.sock &>/var/log/dockerd.log &
  sleep 5
fi

# ensure k3d is available
echo "k3d version: $(k3d version || true)"
echo "kubectl version: $(kubectl version --client=true || true)"
echo "helm version: $(helm version --short || true)"

CLUSTER_NAME=wiki-cluster

# delete cluster if exists
if k3d cluster list | grep -q "${CLUSTER_NAME}" ; then
  echo "Deleting existing k3d cluster ${CLUSTER_NAME}"
  k3d cluster delete "${CLUSTER_NAME}" || true
fi

# create k3d cluster with a LoadBalancer and map container port 8080 to LB port 80
k3d cluster create "${CLUSTER_NAME}" \
  --servers 1 --agents 0 \
  --port "8080:80@loadbalancer"

# configure kubeconfig to use k3d cluster
export KUBECONFIG="$(k3d kubeconfig write ${CLUSTER_NAME})"
echo "KUBECONFIG set"

# wait for kubernetes api
echo "Waiting for Kubernetes API to be ready..."
until kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

kubectl wait --for=condition=Ready node --all --timeout=180s

# wait for core dns
kubectl wait --for=condition=available deployment/coredns \
  -n kube-system \
  --timeout=180s

# Build the wiki-service image inside the container and load into k3d
echo "Building wiki-service image..."
cd /workspace/wiki-service
docker build -t wiki-service:local . 

echo "Loading image into k3d..."
k3d image import wiki-service:local -c ${CLUSTER_NAME}

# Install the helm chart
echo "Installing helm chart..."
cd /workspace/wiki-chart

helm upgrade --install wiki-release . \
  --namespace wiki \
  --create-namespace \
  --set fastapi.image_name=wiki-service:local


echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -n wiki -l app=fastapi --timeout=180s || true
kubectl get pods -n wiki

echo "Setup complete. The cluster maps loadbalancer port 80 to container port 8080."
echo "Access endpoints via host container's port 8080 (container must be run with -p 8080:8080)."
echo "Paths:"
echo "  /users/* and /posts/* -> FastAPI"
echo "  /grafana/d/creation-dashboard-678/creation -> Grafana"

# Keep container alive so the services persist
tail -f /dev/null
