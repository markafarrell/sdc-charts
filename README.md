# sdc-charts

## Update crds

You can also update CRDs automatically using the Makefile target added to this repository. The target reads the `configServer.image.tag` from `charts/sdc/values.yaml`, checks out that version in the `config-server` repository, and copies the `artifacts/inv.sdcio.*` files into both charts.

```bash
# clone upstream and update charts (default repo)
make update-crds

# override the repo if you want a fork
make update-crds CONFIG_SERVER_REPO=https://github.com/youruser/config-server.git
```

## Render Chart

```bash
make render-sdc
make render-sdc-crds
```

## Package chart

```bash
make package-sdc CHART_VERSION=2.x.x
make package-sdc-crds CHART_VERSION=2.x.x
```

## Test

```bash
cd tests
./start.sh
./test.sh
```

## Install

```bash
CHART_VERSION=v2.x.x
helm upgrade --install --create-namespace --namespace network-system sdc oci://ghcr.io/markafarrell/sdc-charts/sdc:$CHART_VERSION
```
