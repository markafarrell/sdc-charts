.PHONY: test-integration render-sdc render-sdc-crds render-charts package-sdc package-sdc-crds package-charts

NAMESPACE ?= network-system
HELM ?= helm
YQ ?= yq
HELM_VERSION ?= v1.x.x
CHART_SDC ?= charts/sdc
CHART_CRDS ?= charts/sdc-crds
CONFIG_SERVER_REPO ?= https://github.com/sdcio/config-server.git

test-integration:
	@echo "Starting minikube and installing chart..."
	@chmod +x tests/start_minikube.sh
	@./tests/start_minikube.sh

render-sdc:
	@echo "Rendering $(CHART_SDC) to stdout"
	@$(HELM) template --namespace $(NAMESPACE) --create-namespace --include-crds $(CHART_SDC)

render-sdc-crds:
	@echo "Rendering $(CHART_CRDS) to stdout"
	@$(HELM) template --namespace $(NAMESPACE) --create-namespace $(CHART_CRDS)

render-charts: render-sdc render-sdc-crds
	@echo "Rendered all charts"

package-sdc:
	@echo "Packaging $(CHART_SDC) with app-version from $(CHART_SDC)/values.yaml"
	@APP_VERSION="$$( $(YQ) -r '.configServer.image.tag' $(CHART_SDC)/values.yaml )"; \
	if [ -z "$$APP_VERSION" ] || [ "$$APP_VERSION" = "null" ]; then \
		echo "ERROR: could not read configServer.image.tag from $(CHART_SDC)/values.yaml" >&2; exit 1; \
	fi; \
	$(HELM) package $(CHART_SDC) --version $(HELM_VERSION) --app-version "$$APP_VERSION"

package-sdc-crds:
	@echo "Packaging $(CHART_CRDS) with app-version from $(CHART_SDC)/values.yaml"
	@APP_VERSION="$$( $(YQ) -r '.configServer.image.tag' $(CHART_SDC)/values.yaml )"; \
	if [ -z "$$APP_VERSION" ] || [ "$$APP_VERSION" = "null" ]; then \
		echo "ERROR: could not read configServer.image.tag from $(CHART_SDC)/values.yaml" >&2; exit 1; \
	fi; \
	$(HELM) package $(CHART_CRDS) --version $(HELM_VERSION) --app-version "$$APP_VERSION"

package-charts: package-sdc package-sdc-crds
	@echo "Packaged all charts"

.PHONY: test-notconf

test-notconf:
	@echo "Run start_notconf.sh (set NOTCONF_IMAGE env var to the notconf-ietf image)"
	@chmod +x tests/start_notconf.sh
	@./tests/start_notconf.sh

.PHONY: test-apply-sdc

test-apply-sdc:
	@echo "Applying tests/artifacts/sdc.yml and checking CR readiness"
	@chmod +x tests/apply_sdc_artifacts_test.sh
	@./tests/apply_sdc_artifacts_test.sh

.PHONY: test-all

test-all:
	@echo "Running all tests (integration, notconf, apply-sdc)"
	@chmod +x tests/run_all_tests.sh
	@./tests/run_all_tests.sh

update-crds:
	@echo "Updating CRDs from $(CONFIG_SERVER_REPO) using app version from $(CHART_SDC)/values.yaml"
	@tmpdir=$$(mktemp -d); \
	set -e; \
	git clone "$(CONFIG_SERVER_REPO)" $$tmpdir >/dev/null 2>&1; \
	APP_VERSION="$$( $(YQ) -r '.configServer.image.tag' $(CHART_SDC)/values.yaml )"; \
	if [ -z "$$APP_VERSION" ] || [ "$$APP_VERSION" = "null" ]; then \
		echo "ERROR: could not read configServer.image.tag from $(CHART_SDC)/values.yaml" >&2; rm -rf $$tmpdir; exit 1; \
	fi; \
	cd $$tmpdir; \
	git fetch --all --tags >/dev/null 2>&1 || true; \
	git checkout "$$APP_VERSION" >/dev/null 2>&1 || true; \
	mkdir -p $(CHART_SDC)/crds $(CHART_CRDS)/templates; \
	cp -v $$tmpdir/artifacts/inv.sdcio.* $(CHART_SDC)/crds/; \
	cp -v $$tmpdir/artifacts/inv.sdcio.* $(CHART_CRDS)/templates/; \
	rc=$$?; \
	rm -rf $$tmpdir; \
	if [ $$rc -ne 0 ]; then echo "Warning: some copy operations failed"; exit $$rc; fi; \
	echo "CRDs updated in $(CHART_SDC)/crds and $(CHART_CRDS)/templates"
