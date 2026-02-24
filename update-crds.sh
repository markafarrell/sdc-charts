#!/usr/bin/env bash
set -eou pipefail

function main() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    local APP_VERSION="$(yq -r '.controller.image.tag' $SCRIPT_DIR/charts/sdc/values.yaml )"

    local tmpdir=$(mktemp -d)

    CONFIG_SERVER_REPO=${CONFIG_SERVER_REPO:-"https://github.com/sdcio/config-server.git"}

    printf "Cloning $CONFIG_SERVER_REPO to $tmpdir.\n"
    git clone $CONFIG_SERVER_REPO $tmpdir

    pushd $tmpdir

    git fetch --all --tags
    git checkout $APP_VERSION

    popd

    printf "Removing existing CRDs from $SCRIPT_DIR/charts/sdc/crds and $SCRIPT_DIR/charts/sdc-crds/templates.\n"
    mkdir -p $SCRIPT_DIR/charts/sdc/crds $SCRIPT_DIR/charts/sdc-crds/templates
    rm -rf $SCRIPT_DIR/charts/sdc/crds/inv.sdcio.*
    rm -rf $SCRIPT_DIR/charts/sdc-crds/templates/inv.sdcio.*

    printf "Copying new CRDs from $tmpdir/artifacts to $SCRIPT_DIR/charts/sdc/crds.\n"
    cp -v $tmpdir/artifacts/inv.sdcio.* $SCRIPT_DIR/charts/sdc/crds/
    printf "Copying new CRDs from $tmpdir/artifacts to $SCRIPT_DIR/charts/sdc-crds/templates/.\n"
    cp -v $tmpdir/artifacts/inv.sdcio.* $SCRIPT_DIR/charts/sdc-crds/templates/
}

main "$@"
