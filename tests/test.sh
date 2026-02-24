



#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    source ${SCRIPT_DIR}/scripts/configure-notconf.sh

    set +e

    local TESTS_PASSED=0

    # wait for namespace to be deleted and recreated

    local TRIES=0
    local INTERVAL=10
    local MAX_TRIES=30 # 300 seconds or 5 minutes

    local TEST_CONFIG_APPLIED_RESULT=1 # Default failed

    while [[ $TRIES -lt $MAX_TRIES ]]; do
        sleep $INTERVAL
        CONFIG_APPLIED=$(kubectl --context=minikube get config -n notconf customer-notconf-test -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')

        if [[ "$CONFIG_APPLIED" == "True" ]]; then
            TEST_CONFIG_APPLIED_RESULT=0
            break
        fi

        printf "===== ⏱️ Waiting for config to be applied. ⏱️ =====\n"
    done

    if [[ "$TEST_CONFIG_APPLIED_RESULT" -eq 0 ]]; then
        printf "===== Config applied test passed ✅ =====\n"
    else
        printf "===== Config applied test failed ❌ =====\n"
    fi

    TESTS_PASSED=$([[ $TESTS_PASSED || $TEST_CONFIG_APPLIED_RESULT ]])

    if [[ "$TESTS_PASSED" -eq 0 ]]; then
        printf "===== All tests passed ✅ =====\n"
    fi

    kubectl --context=minikube get config -n notconf customer-notconf-test -o yaml

    kubectl --context=minikube get runningconfig -n notconf notconf-test -o yaml

    exit $TESTS_PASSED
}

main "$@"
