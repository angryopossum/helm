{{- define "redis-tls.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "redis-tls.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "redis-tls.name" . -}}
{{- end -}}
{{- end -}}

{{- define "redis-tls.labels" -}}
helm.sh/chart: "{{ include "redis-tls.name" . }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/name: "{{ include "redis-tls.name" . }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
{{- end -}}


