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

You can also update CRDs automatically using the Makefile target added to this repository. The target reads the `configServer.image.tag` from `charts/sdc/values.yaml`, checks out that version in the `config-server` repository, and copies the `artifacts/inv.sdcio.*` files into both charts.

```bash
# clone upstream and update charts (default repo)
make update-crds

# override the repo if you want a fork
make update-crds CONFIG_SERVER_REPO=https://github.com/youruser/config-server.git
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

## Run integration test (minikube)

The repository includes a minikube integration test script at `tests/minikube_integration_test.sh` which:

- Starts a local Minikube cluster
- Installs the `sdc` Helm chart into the `network-system` namespace
- Waits for all pods to become Ready and fails the run if any pod is unhealthy

To run the test locally:

```bash
chmod +x tests/minikube_integration_test.sh
./tests/minikube_integration_test.sh
```

Optional environment variables:

- `NAMESPACE` — namespace to install into (default: `network-system`)
- `RELEASE` — Helm release name (default: `sdc`)
- `CHART_PATH` — path to the chart (default: `charts/sdc`)
- `POD_WAIT_TIMEOUT` — timeout for pods to become ready (default: `600s`)

Notes:

- The script will delete any existing Minikube cluster and start a fresh one. This may take a few minutes.
- Ensure `minikube`, `kubectl` and `helm` are installed and available on your PATH before running the script.
- If you prefer to run Minikube with a specific driver, set the `MINIKUBE_DRIVER` environment variable and modify the `minikube start` command in the script accordingly.

### Deploy a notconf-ietf container to Minikube

There is a dedicated test script that deploys a `notconf-ietf` container to Minikube. The script requires you to provide the image to deploy via the `NOTCONF_IMAGE` environment variable.

```bash
# Example using a hypothetical image (replace with the actual notconf-ietf image you want):
NOTCONF_IMAGE=ghcr.io/your/repo/notconf-ietf:tag make test-notconf

# Or run script directly:
NOTCONF_IMAGE=ghcr.io/your/repo/notconf-ietf:tag ./tests/deploy_notconf_test.sh
```

Notes:

- The script will start a fresh Minikube cluster (it runs `minikube delete --all` then `minikube start`).
- Ensure `NOTCONF_IMAGE` points to an accessible container image (public registry or preloaded in Minikube).
- The script creates a Pod named `notconf-test` (or override by setting `RELEASE`) in the `network-system` namespace, waits for it to become Ready, prints logs, and then deletes the Pod.

## Values (charts/sdc/values.yaml)

This chart exposes several top-level keys you can override via a custom `values.yaml` or `--set` flags.

- `rbac.create` (bool): create RBAC resources (default: `true`).
- `serviceAccount.create` (bool) and `serviceAccount.name` (string): create and name the ServiceAccount (default: `true`, `config-server`).
- `global.imageRegistry` (string): optional global image registry prefix (default: empty).

- `configServer.image`: image settings for the config server
	- `registry` (string): image registry (default: `ghcr.io`)
	- `repository` (string): image repo (default: `sdcio/config-server`)
	- `tag` (string): image tag (default shown in `charts/sdc/values.yaml`)
	- `pullPolicy` (string): image pull policy (default: `IfNotPresent`)

- `configServer.persistentVolume`: PVC settings
	- `size` (string): volume size (default: `10Gi`)
	- `accessModes` (array): e.g. `ReadWriteOnce`.

- `configServer.env` (map): environment variables passed to the server (feature flags and ports).
- `configServer.extraArgs` (map): additional CLI args for the server.
- `configServer.resources` (requests/limits): CPU and memory defaults for the server.

- `dataServer.image`, `dataServer.persistentVolume`, and `dataServer.resources`: same structure as `configServer` for the data server component.

- `schemaServer.persistentVolume` and `workspace.persistentVolume`: persistence settings for schema and workspace stores.

To customize values when packaging or installing, either edit `charts/sdc/values.yaml` or pass overrides with Helm, for example:

```bash
helm upgrade --install sdc charts/sdc --namespace network-system --create-namespace \
	--set configServer.image.tag=v1.2.3
```


## Install

```bash
CHART_VERSION=v2.x.x
helm upgrade --install --create-namespace --namespace network-system sdc oci://ghcr.io/markafarrell/sdc-charts/sdc:$CHART_VERSION
```
