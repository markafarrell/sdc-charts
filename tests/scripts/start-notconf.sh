#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "🚀 ===== Starting notconf ===== 🚀\n"

    kubectl --context=minikube apply -f $SCRIPT_DIR/../manifests/notconf.yml

    kubectl --context=minikube \
        -n notconf \
        rollout status deployment/notconf --timeout=300s

    printf "🚀 ===== notconf started ===== 🚀\n"

}

main "$@"
