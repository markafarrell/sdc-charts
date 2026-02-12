# sdc-charts

## Update crds

```bash
git clone https://github.com/sdcio/config-server.git

APP_VERSION=$(yq -r '.configServer.image.tag' charts/sdc/values.yaml)

cd config-server
git checkout $APP_VERSION

cd ..

cp config-server/artifacts/inv.sdcio.* charts/sdc/crds
cp config-server/artifacts/inv.sdcio.* charts/sdc-crds/templates
```

## Render Chart

```bash
helm template --namespace network-system --create-namespace --include-crds charts/sdc
```

## Package chart

```bash
APP_VERSION=$(yq -r '.configServer.image.tag' charts/sdc/values.yaml)
HELM_VERSION=v1.x.x
helm package ./charts/sdc --version $HELM_VERSION --app-version $APP_VERSION
helm package ./charts/sdc-crds --version $HELM_VERSION --app-version $APP_VERSION
```

## Install

```bash
HELM_VERSION=v1.x.x
helm upgrade --install --create-namespace --namespace network-system sdc oci://ghcr.io/markafarrell/sdc-charts/sdc:$HELM_VERSION
```
