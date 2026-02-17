# sdc-charts

## Update crds

```bash
git clone https://github.com/sdcio/config-server.git

APP_VERSION=$(yq -r '.controller.image.tag' charts/sdc/values.yaml)

cd config-server
git checkout $APP_VERSION

cd ..

cp config-server/artifacts/inv.sdcio.* charts/sdc/crds
cp config-server/artifacts/inv.sdcio.* charts/sdc-crds/templates
```

## Render Chart

```bash
helm template --namespace sdc-system --create-namespace --include-crds charts/sdc
```

## Package chart

```bash
APP_VERSION=$(yq -r '.controller.image.tag' charts/sdc/values.yaml)
CHART_VERSION=v2.x.x
helm package ./charts/sdc --version $CHART_VERSION --app-version $APP_VERSION
helm package ./charts/sdc-crds --version $CHART_VERSION --app-version $APP_VERSION
```

## Test

```bash
minikube delete --all
minikube start --embed-certs

helm upgrade --install --create-namespace --namespace sdc-system sdc-crds sdc-crds-$CHART_VERSION.tgz --wait
helm upgrade --install --create-namespace --namespace sdc-system sdc sdc-$CHART_VERSION.tgz --wait
```

## Install

```bash
CHART_VERSION=v2.x.x
helm upgrade --install --create-namespace --namespace network-system sdc oci://ghcr.io/markafarrell/sdc-charts/sdc:$CHART_VERSION
```
