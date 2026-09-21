#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    pushd $SCRIPT_DIR/../ >/dev/null

    make render-sdc > $SCRIPT_DIR/helm-manifest.yml

    popd >/dev/null

    kubectl kustomize . > kustomized-helm-manifest.yml
}

main "$@"
