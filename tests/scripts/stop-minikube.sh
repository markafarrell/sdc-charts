#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    printf "💣 ===== Killing existing minikube instances ===== 💣\n"
    minikube delete || true
}

main "$@"
