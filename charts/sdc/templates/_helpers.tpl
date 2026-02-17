{{- define "api-server.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.apiServer.image.repository .Values.apiServer.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.apiServer.image.registry .Values.apiServer.image.repository .Values.apiServer.image.tag }}
{{- end }}
{{- end }}

{{- define "controller.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.controller.image.repository .Values.controller.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.controller.image.registry .Values.controller.image.repository .Values.controller.image.tag }}
{{- end }}
{{- end }}

{{- define "data-server-controller.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.dataServer.images.controller.repository .Values.dataServer.images.controller.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.dataServer.images.controller.registry .Values.dataServer.images.controller.repository .Values.dataServer.images.controller.tag }}
{{- end }}
{{- end }}

{{- define "data-server-server.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.dataServer.images.server.repository .Values.dataServer.images.server.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.dataServer.images.server.registry .Values.dataServer.images.server.repository .Values.dataServer.images.server.tag }}
{{- end }}
{{- end }}


{{- define "sdc.name" -}}
{{- default "config-server" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sdc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sdc.selectorLabels" }}
app.kubernetes.io/name: {{ include "sdc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sdc.labels" -}}
helm.sh/chart: {{ include "sdc.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "sdc.name" . }}
{{- include "sdc.selectorLabels" . }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}
