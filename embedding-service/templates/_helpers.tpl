{{/* Expand the name of the chart */}}
{{- define "embeddingService.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create chart name and version as used by the chart label */}}
{{- define "embeddingService.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "embeddingService.labels" -}}
helm.sh/chart: {{ include "embeddingService.chart" . }}
{{ include "embeddingService.selector" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "embeddingService.selector" -}}
app.kubernetes.io/name: {{ include "embeddingService.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}