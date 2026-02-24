#!/usr/bin/env bash
set -euo pipefail

# Start a notconf-sros container in Minikube and validate Pod readiness.
# Usage:
#   NOTCONF_IMAGE=ghcr.io/your/repo/notconf-sros:tag ./tests/start_notconf.sh

NAMESPACE=${NAMESPACE:-network-system}
RELEASE=${RELEASE:-notconf-test}
# Default notconf-sros image; can be overridden via NOTCONF_IMAGE env var
NOTCONF_IMAGE=${NOTCONF_IMAGE:-ghcr.io/notconf/notconf-sros:22.2}
POD_WAIT_TIMEOUT=${POD_WAIT_TIMEOUT:-300s}
NOTCONF_USER=${NOTCONF_USER:-admin}
# Default password for notconf (can be overridden via env)
NOTCONF_PASS=${NOTCONF_PASS:-admin}

if [ -z "${NOTCONF_IMAGE}" ]; then
  echo "ERROR: NOTCONF_IMAGE must be set to the notconf-sros image to deploy." >&2
  echo "Example: NOTCONF_IMAGE=ghcr.io/your/repo/notconf-sros:tag ./tests/start_notconf.sh" >&2
  exit 2
fi

echo "==> Starting/ensuring Minikube cluster"
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "==> Creating namespace '$NAMESPACE'"
kubectl create ns "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "==> Rendering deployment manifest from template with image: $NOTCONF_IMAGE"
tmp_manifest=$(mktemp -t notconf-deploy-XXXX.yaml)
sed -e "s|__IMAGE__|${NOTCONF_IMAGE}|g" -e "s|__RELEASE__|${RELEASE}|g" tests/artifacts/notconf-deployment.yaml.template > $tmp_manifest

echo "==> Rendering and applying NetworkPolicy to allow ingress on port 830"
tmp_np=$(mktemp -t notconf-np-XXXX.yaml)
sed -e "s|__RELEASE__|${RELEASE}|g" tests/artifacts/notconf-networkpolicy.yaml.template > $tmp_np
kubectl apply -f $tmp_np -n "$NAMESPACE"

echo "==> Applying deployment manifest"
kubectl apply -f $tmp_manifest -n "$NAMESPACE"

echo "==> Waiting for deployment rollout (timeout: $POD_WAIT_TIMEOUT)"
kubectl rollout status deployment/"$RELEASE" -n "$NAMESPACE" --timeout="$POD_WAIT_TIMEOUT"

echo "==> Waiting for Pod to become Ready (timeout: $POD_WAIT_TIMEOUT)"
kubectl wait --for=condition=Ready pod -l app="$RELEASE" -n "$NAMESPACE" --timeout="$POD_WAIT_TIMEOUT"

echo "==> Pod is Ready. Pod details:"
kubectl get pods -l app="$RELEASE" -n "$NAMESPACE" -o wide

echo "==> Fetching logs (tail 100 lines)"
kubectl logs --tail=100 -n "$NAMESPACE" -l app="$RELEASE" || true

echo "==> Rendering and applying service manifest targeting port 830"
tmp_svc=$(mktemp -t notconf-svc-XXXX.yaml)
sed -e "s|__RELEASE__|${RELEASE}|g" tests/artifacts/notconf-service.yaml.template > $tmp_svc
kubectl apply -f $tmp_svc -n "$NAMESPACE"

echo "==> Verifying service port"
svc_port=$(kubectl get svc/"$RELEASE" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || true)
if [ "$svc_port" != "830" ]; then
  echo "ERROR: Service port is not 830 (found: $svc_port)" >&2
  kubectl get svc -n "$NAMESPACE" "$RELEASE" -o yaml
  kubectl delete deployment -n "$NAMESPACE" "$RELEASE" --ignore-not-found || true
  kubectl delete svc -n "$NAMESPACE" "$RELEASE" --ignore-not-found || true
  rm -f $tmp_manifest $tmp_svc
  exit 1
fi

rm -f $tmp_manifest $tmp_svc
rm -f $tmp_np || true

echo "notconf-sros deployment started"

exit 0
