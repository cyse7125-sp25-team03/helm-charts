{{/*
Common labels for the API server
*/}}
{{- define "apiServer.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/component: backend
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector for API server pods
*/}}
{{- define "apiServer.selector" -}}
app: {{ .Values.apiServer.name }}
{{- end }}
