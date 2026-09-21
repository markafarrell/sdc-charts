#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    curl -L https://docs.sdcio.dev/artifacts/basic-usage/installation.yaml --output installation-manifest.yml
}

main "$@"
