{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sidecar-injector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "is-openshift-4" -}}
{{- if .Capabilities.APIVersions.Has "ingress.operator.openshift.io/v1" -}}
true
{{- end -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sidecar-injector.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sidecar-injector.chart" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return instance and name labels.
*/}}
{{- define "sidecar-injector.instance-name" -}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/name: {{ include "sidecar-injector.name" . | quote }}
{{- end -}}

{{/*
Return labels, including instance and name.
*/}}
{{- define "sidecar-injector-common.labels" -}}
{{ include "sidecar-injector.instance-name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
helm.sh/chart: {{ include "sidecar-injector.chart" . | quote }}
{{- end -}}

{{- define "sidecar-injector.labels" -}}
{{ include "sidecar-injector-common.labels" . }}
app.kubernetes.io/component: cloudbees-sidecar-injector
{{- end -}}

{{- define "sidecar-injector-init.labels" -}}
{{ include "sidecar-injector-common.labels" . }}
app.kubernetes.io/component: cloudbees-sidecar-injector-init
{{- end -}}

{{- define "os.label" -}}
kubernetes.io/os
{{- end -}}

{{- define "sidecar-injector.init-job.spec" -}}
spec:
  template:
    metadata:
      annotations:
        {{ .Values.annotationPrefix }}/inject: "false"
        {{- if .Values.podAnnotations }}
{{ toYaml .Values.podAnnotations | indent 8 }}
        {{- end }}
    spec:
      nodeSelector:
        # Schedule on linux nodes only.
        {{ include "os.label" . }}: linux
        {{- if .Values.nodeSelector }}
{{ toYaml .Values.nodeSelector | indent 8 }}
        {{- end }}
      serviceAccountName: {{ .Values.rbac.initServiceAccountName }}
      restartPolicy: OnFailure
      containers:
      # The init-certs container sends a certificate signing request to the
      # kubernetes cluster.
      # You can see pending requests using: kubectl get csr
      # CSRs can be approved using:         kubectl certificate approve <csr name>
      - name: init-certs
{{- if contains "/" .Values.requestCert.image }}
        image: "{{ .Values.requestCert.image }}"
{{- else }}
        image: "{{ .Values.hub }}/{{ .Values.requestCert.image }}:{{ .Values.requestCert.tag }}"
{{- end }}
        imagePullPolicy: "{{ .Values.ImagePullPolicy }}"
        args:
        - "--serviceName={{ .Values.serviceName }}"
      {{- if .Values.tolerations }}
      tolerations:
{{ toYaml .Values.tolerations | indent 6 }}
      {{- end }}
{{- end -}}
