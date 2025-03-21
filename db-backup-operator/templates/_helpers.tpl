{{/*
Common labels for the Backup Operator
 */}}
{{- define "dbOperator.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: backend
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}