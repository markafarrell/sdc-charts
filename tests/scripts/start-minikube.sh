#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "🚀 ===== Starting Minikube ===== 🚀\n"
    minikube start --embed-certs
    minikube addons enable metrics-server
}

main "$@"
