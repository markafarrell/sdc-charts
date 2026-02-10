{{- define "config-server.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.configServer.image.repository .Values.configServer.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.configServer.image.registry .Values.configServer.image.repository .Values.configServer.image.tag }}
{{- end }}
{{- end }}

{{- define "data-server.image" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.dataServer.image.repository .Values.dataServer.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" .Values.dataServer.image.registry .Values.dataServer.image.repository .Values.dataServer.image.tag }}
{{- end }}
{{- end }}
