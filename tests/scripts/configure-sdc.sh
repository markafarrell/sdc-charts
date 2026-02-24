#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "🚀 ===== Configuring sdc ===== 🚀\n"

    kubectl --context=minikube apply -f $SCRIPT_DIR/../manifests/sdc-schema.yml
    printf "⏱️ ===== Waiting for schema to be ready ===== ⏱️\n"
    kubectl --context=minikube wait -n notconf --for=condition=Ready schema/sros.nokia.sdcio.dev-22.2.1 --timeout=600s

    kubectl --context=minikube apply -f $SCRIPT_DIR/../manifests/sdc-config.yml

    printf "⏱️ ===== Waiting for target to be ready ===== ⏱️\n"
    kubectl --context=minikube wait -n notconf --for=create target/notconf-test --timeout=60s

    while [[ $(kubectl --context=minikube get target -n notconf notconf-test -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
        sleep 2
    done

    printf "🚀 ===== sdc configured ===== 🚀\n"
}

main "$@"
