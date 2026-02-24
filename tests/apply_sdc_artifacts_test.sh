#!/usr/bin/env bash
set -euo pipefail

# Apply tests/artifacts/sdc.yml and wait for custom resources with a Ready condition
# Usage: ./tests/apply_sdc_artifacts_test.sh

FILE=${FILE:-tests/artifacts/sdc.yml}
NAMESPACE=${NAMESPACE:-network-system}
TIMEOUT=${TIMEOUT:-300}

if [ ! -f "$FILE" ]; then
  echo "ERROR: file $FILE not found" >&2
  exit 2
fi

echo "==> Applying $FILE"
applied=$(kubectl apply -f "$FILE" -o name)
echo "$applied"

if [ -z "$applied" ]; then
  echo "No resources applied from $FILE" >&2
  exit 1
fi

echo "==> Checking Ready conditions where available"
failed=0
for res in $applied; do
  # res is like "configset.config.sdcio.dev/customer" or "schema.inv.sdcio.dev/sros..."
  kind=$(kubectl get "$res" -o jsonpath='{.kind}' 2>/dev/null || true)
  name=$(kubectl get "$res" -o jsonpath='{.metadata.name}' 2>/dev/null || true)
  ns=$(kubectl get "$res" -o jsonpath='{.metadata.namespace}' 2>/dev/null || echo "$NAMESPACE")
  echo "-> Resource: $kind $name (namespace: $ns)"

  # Check if resource exposes status.conditions with a Ready condition
  has_ready=$(kubectl get "$res" -o jsonpath='{.status.conditions[?(@.type=="Ready")].type}' 2>/dev/null || true)
  if [ -z "$has_ready" ]; then
    echo "   - No Ready condition exposed; skipping readiness check"
    continue
  fi

  echo "   - Waiting for Ready=true (timeout: ${TIMEOUT}s)"
  end=$((SECONDS+TIMEOUT))
  success=0
  while [ $SECONDS -lt $end ]; do
    status=$(kubectl get "$res" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
    if [ "$status" = "True" ]; then
      echo "   - Ready=true"
      success=1
      break
    fi
    sleep 2
  done
  if [ $success -ne 1 ]; then
    echo "   - ERROR: resource $kind/$name did not reach Ready=true within ${TIMEOUT}s" >&2
    kubectl get "$res" -n "$ns" -o yaml || true
    failed=1
  fi
done

if [ $failed -ne 0 ]; then
  echo "One or more resources failed readiness checks" >&2
  exit 3
fi

echo "All applicable resources are Ready or do not expose a Ready condition. Test passed."
exit 0
