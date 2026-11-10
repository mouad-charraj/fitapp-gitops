{{- define "ms.name" -}}{{ .Release.Name }}{{- end -}}

{{- define "ms.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/part-of: fitapp
app.kubernetes.io/managed-by: argocd
env: {{ .Values.env }}
{{- end -}}

{{- define "ms.selector" -}}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end -}}

{{- define "ms.host" -}}
{{- if eq .Values.env "prod" -}}
{{ .Release.Name }}.{{ .Values.domain }}
{{- else -}}
{{ .Release.Name }}-{{ .Values.env }}.{{ .Values.domain }}
{{- end -}}
{{- end -}}
