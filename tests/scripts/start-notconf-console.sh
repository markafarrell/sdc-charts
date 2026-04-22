#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "🚀 ===== Starting notconf-console ===== 🚀\n"

    kubectl --context=minikube apply -f $SCRIPT_DIR/../manifests/notconf-console.yml

    kubectl --context=minikube \
        -n notconf \
        rollout status deployment/notconf-console --timeout=300s

    printf "🚀 ===== notconf-console started ===== 🚀\n"

}

main "$@"
