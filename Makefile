.PHONY: update-crds test-integration render-sdc render-sdc-crds render-charts package-sdc package-sdc-crds package-charts

NAMESPACE ?= sdc-system
HELM ?= helm
YQ ?= yq
CHART_SDC ?= charts/sdc
CHART_CRDS ?= charts/sdc-crds

render-sdc: update-crds
	@echo "Rendering $(CHART_SDC) to stdout" >&2
	@$(HELM) template --namespace $(NAMESPACE) --create-namespace --include-crds $(CHART_SDC)

render-sdc-crds: update-crds
	@echo "Rendering $(CHART_CRDS) to stdout" >&2
	@$(HELM) template --namespace $(NAMESPACE) --create-namespace $(CHART_CRDS)

render-charts: render-sdc render-sdc-crds
	@echo "Rendered all charts" >&2

package-sdc: update-crds
	@echo "Packaging $(CHART_SDC) with app-version from $(CHART_SDC)/values.yaml"
	@APP_VERSION="$$( $(YQ) -r '.controller.image.tag' $(CHART_SDC)/values.yaml )"; \
	if [ -z "$$APP_VERSION" ] || [ "$$APP_VERSION" = "null" ]; then \
		echo "ERROR: could not read controller.image.tag from $(CHART_SDC)/values.yaml" >&2; exit 1; \
	fi; \
	$(HELM) package $(CHART_SDC) --version $(CHART_VERSION) --app-version "$$APP_VERSION"

package-sdc-crds: update-crds
	@echo "Packaging $(CHART_CRDS) with app-version from $(CHART_SDC)/values.yaml"
	@APP_VERSION="$$( $(YQ) -r '.controller.image.tag' $(CHART_SDC)/values.yaml )"; \
	if [ -z "$$APP_VERSION" ] || [ "$$APP_VERSION" = "null" ]; then \
		echo "ERROR: could not read controller.image.tag from $(CHART_SDC)/values.yaml" >&2; exit 1; \
	fi; \
	$(HELM) package $(CHART_CRDS) --version $(CHART_VERSION) --app-version "$$APP_VERSION"

package-charts: package-sdc package-sdc-crds
	@echo "Packaged all charts"

update-crds:
	@./update-crds.sh
