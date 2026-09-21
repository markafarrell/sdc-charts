#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    source $SCRIPT_DIR/get-latest-published-manifest.sh
    source $SCRIPT_DIR/generate-manifest-from-helm.sh

    dyff between installation-manifest.yml kustomized-helm-manifest.yml
}

main "$@"
