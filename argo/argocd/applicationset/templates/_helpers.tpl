{{/* Expand the name of the chart. */}}
{{- define "serviceapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "serviceapp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "serviceapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "serviceapp.labels" -}}
helm.sh/chart: {{ include "serviceapp.chart" . }}
{{ include "serviceapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "serviceapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "serviceapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Create the name of the service account to use */}}
{{- define "serviceapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "serviceapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/* Environment variables to be injected into every workload */}}
{{- define "serviceapp.environmentVariables" -}}
{{- range $name, $value := (get (get .Values (.Values.environment)) "env") }}
{{- if kindIs "map" $value }}
- name: {{ $name }}
  valueFrom:
    {{- toYaml $value | trim | nindent 4 }}
{{- else if or (or (kindIs "int" $value) (kindIs "bool" $value)) (kindIs "float64" $value) }}
- name: {{ $name }}
  value: "{{ $value }}"
{{- else }}
- name: {{ $name }}
  value: "{{ tpl $value $ }}"
{{- end }}
{{- end }}
{{- range $name, $value := .Values.env }}
{{- if kindIs "map" $value }}
- name: {{ $name }}
  valueFrom:
    {{- toYaml $value | trim | nindent 4 }}
{{- else if or (or (kindIs "int" $value) (kindIs "bool" $value)) (kindIs "float64" $value) }}
- name: {{ $name }}
  value: "{{ $value }}"
{{- else }}
- name: {{ $name }}
  value: "{{ tpl $value $ }}"
{{- end }}
{{- end }}
{{- end }}