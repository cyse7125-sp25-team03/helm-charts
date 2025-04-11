{{/*
Common labels for the Trace Processor
*/}}
{{- define "traceProcessor.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: backend
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector for Trace Processor pods
*/}}
{{- define "traceProcessor.selector" -}}
app: {{ .Values.traceProcessor.name }}
{{- end }}