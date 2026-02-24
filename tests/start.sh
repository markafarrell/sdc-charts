#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    source ${SCRIPT_DIR}/scripts/start-minikube.sh
    source ${SCRIPT_DIR}/scripts/install-sdc.sh
    source ${SCRIPT_DIR}/scripts/start-notconf.sh
    source ${SCRIPT_DIR}/scripts/configure-sdc.sh

}

main "$@"
