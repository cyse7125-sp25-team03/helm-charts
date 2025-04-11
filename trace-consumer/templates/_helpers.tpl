{{/*
Common labels for the Trace Consumer
*/}}
{{- define "traceConsumer.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: backend
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector for Trace Consumer pods
*/}}
{{- define "traceConsumer.selector" -}}
app: {{ .Values.traceConsumer.name }}
{{- end }}