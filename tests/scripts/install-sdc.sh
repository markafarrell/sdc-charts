#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "🚀 ===== Installing sdc ===== 🚀\n"

    source ${SCRIPT_DIR}/../../update-crds.sh

    if [[ -f "$SCRIPT_DIR/../manifests/additional-ca-certs.yml" ]]; then
        kubectl --context=minikube apply -f $SCRIPT_DIR/../manifests/additional-ca-certs.yml
    fi

    helm --kube-context=minikube \
        upgrade --install \
        sdc \
        $SCRIPT_DIR/../../charts/sdc \
        --namespace network-system \
        --create-namespace \
        --wait

    printf "🚀 ===== sdc installed ===== 🚀\n"
}

main "$@"
