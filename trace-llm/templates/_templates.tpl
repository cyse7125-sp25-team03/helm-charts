{{/* Expand the name of the chart */}}
{{- define "traceLlm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create chart name and version as used by the chart label */}}
{{- define "traceLlm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "traceLlm.labels" -}}
helm.sh/chart: {{ include "traceLlm.chart" . }}
{{ include "traceLlm.selector" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "traceLlm.selector" -}}
app.kubernetes.io/name: {{ include "traceLlm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}