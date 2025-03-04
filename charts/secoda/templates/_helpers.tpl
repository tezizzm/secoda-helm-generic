{{/*
Expand the name of the chart.
*/}}
{{- define "secoda.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "secoda.fullname" -}}
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

{{- define "secoda.fullnameApi" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 59 | trimSuffix "-" }}-api
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 59 | trimSuffix "-" }}-api
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 59 | trimSuffix "-" }}-api
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "secoda.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "secoda.labels" -}}
helm.sh/chart: {{ include "secoda.chart" . }}
{{ include "secoda.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "secoda.labelsApi" -}}
helm.sh/chart: {{ include "secoda.chart" . }}
{{ include "secoda.selectorLabelsApi" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "secoda.selectorLabels" -}}
app.kubernetes.io/name: {{ include "secoda.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "secoda.selectorLabelsApi" -}}
app.kubernetes.io/name: {{ include "secoda.name" . }}-api
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "secoda.selectorLabelsReis" -}}
app.kubernetes.io/name: {{ include "secoda.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{/*
Create the name of the service account to use
*/}}
{{- define "secoda.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "secoda.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL connection details
*/}}
{{- define "secoda.postgresql.host" -}}
{{- if .Values.externalServices.postgres.external }}
{{- .Values.externalServices.postgres.host }}
{{- else if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else }}
{{- fail "PostgreSQL is not enabled and no external PostgreSQL is configured" }}
{{- end }}
{{- end }}

{{- define "secoda.postgresql.port" -}}
{{- if .Values.externalServices.postgres.external }}
{{- .Values.externalServices.postgres.port }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{- define "secoda.postgresql.username" -}}
{{- if .Values.externalServices.postgres.external }}
{{- .Values.externalServices.postgres.username }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- fail "PostgreSQL is not enabled and no external PostgreSQL is configured" }}
{{- end }}
{{- end }}

{{- define "secoda.postgresql.password" -}}
{{- if .Values.externalServices.postgres.external }}
{{- .Values.externalServices.postgres.password }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.password }}
{{- else }}
{{- fail "PostgreSQL is not enabled and no external PostgreSQL is configured" }}
{{- end }}
{{- end }}

{{- define "secoda.postgresql.database" -}}
{{- if .Values.externalServices.postgres.external }}
{{- .Values.externalServices.postgres.database }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- fail "PostgreSQL is not enabled and no external PostgreSQL is configured" }}
{{- end }}
{{- end }}

{{/*
Get Redis connection details
*/}}
{{- define "secoda.redis.host" -}}
{{- if .Values.externalServices.redis.external }}
{{- .Values.externalServices.redis.host }}
{{- else if .Values.redis.enabled }}
{{- printf "%s-redis-master" .Release.Name }}
{{- else }}
{{- fail "Redis is not enabled and no external Redis is configured" }}
{{- end }}
{{- end }}

{{- define "secoda.redis.port" -}}
{{- if .Values.externalServices.redis.external }}
{{- .Values.externalServices.redis.port }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
Get OpenSearch connection details
*/}}
{{- define "secoda.opensearch.host" -}}
{{- if .Values.externalServices.opensearch.external }}
{{- .Values.externalServices.opensearch.host }}
{{- else if .Values.opensearch.enabled }}
{{- printf "%s-opensearch" .Release.Name }}
{{- else }}
{{- fail "OpenSearch is not enabled and no external OpenSearch is configured" }}
{{- end }}
{{- end }}

{{- define "secoda.opensearch.port" -}}
{{- if .Values.externalServices.opensearch.external }}
{{- .Values.externalServices.opensearch.port }}
{{- else }}
{{- "9200" }}
{{- end }}
{{- end }}

{{/*
Generate APISERVICE_SECRET
*/}}
{{- define "secoda.apiservice.secret" -}}
{{- if .Values.services.api.secret }}
{{- .Values.services.api.secret }}
{{- else }}
{{- $secret := printf "%s-%s-%s" .Release.Name .Release.Namespace .Release.Revision | sha256sum | trunc 32 }}
{{- $secret }}
{{- end }}
{{- end }}
