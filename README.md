# sdc-charts

## Update crds

```bash
git clone https://github.com/sdcio/config-server.git

APP_VERSION=$(yq -r '.configServer.image.tag' charts/sdc/values.yaml)

cd config-server
git checkout $APP_VERSION
```

## Render Chart

```bash
helm template --namespace network-system --create-namespace --include-crds charts/sdc
```

## Package chart

```bash
APP_VERSION=$(yq -r '.configServer.image.tag' charts/sdc/values.yaml)
HELM_VERSION=0.0.0
helm package ./charts/sdc --version $HELM_VERSION --app-version $APP_VERSION
```

## Install

```bash
HELM_VERSION=0.0.0
helm upgrade --install --create-namespace --namespace network-system oci://ghcr.io/markafarrell/sdc-charts/sdc:$HELM_VERSION
```
