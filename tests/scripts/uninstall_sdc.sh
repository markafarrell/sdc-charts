#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=${NAMESPACE:-network-system}
RELEASE=${RELEASE:-sdc}
CHART_PATH=${CHART_PATH:-charts/sdc}
POD_WAIT_TIMEOUT=${POD_WAIT_TIMEOUT:-600s}
HELM_WAIT_TIMEOUT=${HELM_WAIT_TIMEOUT:-600s}

echo "==> Removing Helm chart '$RELEASE' from namespace '$NAMESPACE'"
helm uninstall "$RELEASE" --namespace "$NAMESPACE"

exit 0
