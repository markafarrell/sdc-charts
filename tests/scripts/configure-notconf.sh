#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "🚀 ===== Configuring notconf ===== 🚀\n"

    kubectl --context=minikube apply -f $SCRIPT_DIR/../manifests/notconf-config.yml

    printf "🚀 ===== notconf configured ===== 🚀\n"

}

main "$@"
