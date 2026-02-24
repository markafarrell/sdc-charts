#!/usr/bin/env bash
set -euo pipefail

# Run all test scripts in order:
# 1) start minikube and install sdc chart
# 2) deploy notconf and run NETCONF client
# 3) apply sdc artifacts and check CR readiness

SCRIPTDIR=$(dirname "$0")

echo "==> Running full test sequence"

echo "[1/3] Starting minikube and installing chart"
chmod +x "$SCRIPTDIR/start_minikube.sh"
"$SCRIPTDIR/start_minikube.sh"

echo "[2/3] Starting notconf and verifying NETCONF client"
chmod +x "$SCRIPTDIR/start_notconf.sh"
"$SCRIPTDIR/start_notconf.sh"

echo "[3/3] Applying sdc artifacts and checking CR readiness"
chmod +x "$SCRIPTDIR/apply_sdc_artifacts_test.sh"
"$SCRIPTDIR/apply_sdc_artifacts_test.sh"

echo "All tests completed successfully"

exit 0
