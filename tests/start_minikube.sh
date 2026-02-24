#!/usr/bin/env bash
set -euo pipefail

# Minikube integration start script: installs the sdc Helm chart and verifies pods are healthy
# Usage: chmod +x tests/start_minikube.sh && ./tests/start_minikube.sh

NAMESPACE=${NAMESPACE:-network-system}
RELEASE=${RELEASE:-sdc}
CHART_PATH=${CHART_PATH:-charts/sdc}
POD_WAIT_TIMEOUT=${POD_WAIT_TIMEOUT:-600s}
HELM_WAIT_TIMEOUT=${HELM_WAIT_TIMEOUT:-600s}

echo "==> Cleaning up any existing minikube cluster"
minikube delete --all || true

echo "==> Starting minikube (this may take a minute)"
minikube start --embed-certs

echo "==> Ensuring nodes are Ready"
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "==> Installing Helm chart $CHART_PATH as release '$RELEASE' into namespace '$NAMESPACE'"
helm upgrade --install "$RELEASE" "$CHART_PATH" --namespace "$NAMESPACE" --create-namespace --wait --timeout="$HELM_WAIT_TIMEOUT"

echo "==> Waiting for all pods in namespace '$NAMESPACE' to become Ready (timeout: $POD_WAIT_TIMEOUT)"
kubectl wait --for=condition=Ready pods --all -n "$NAMESPACE" --timeout="$POD_WAIT_TIMEOUT"

echo "All pods in namespace '$NAMESPACE' are healthy. Test passed."

exit 0
