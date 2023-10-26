{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudbees-core.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Full name of the release
*/}}
{{- define "cloudbees-core.fullname" -}}
{{ printf "%s-%s" .Release.Name .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudbees-core.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mm.longname" -}}
CloudBees CI - Managed Controller - {{ include "mm.longname-suffix" .}}
{{- end -}}

{{/*
If the image is by digest, we assume it is a development image.
If the image is a tag, we use the tag as is.
*/}}
{{- define "mm.longname-suffix" -}}
{{- if contains "@" .Values.Master.Image.dockerImage -}}
DEVELOPMENT
{{- else -}}
{{- (splitn ":" 2 .Values.Master.Image.dockerImage)._1 -}}
{{- end -}}
{{- end -}}

{{/*
Return instance and name labels.
*/}}
{{- define "cloudbees-core.instance-name" -}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/name: {{ include "cloudbees-core.name" . | quote }}
{{- end -}}

{{- define "cloudbees-core.cli" -}}
{{- if include "cloudbees-core.is-openshift" . -}}
oc
{{- else -}}
kubectl
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.needs-routes" -}}
{{- if or (include "cloudbees-core.is-openshift" . ) (.Values.OperationsCenter.Route.tls.Enable) -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.needs-ingress" -}}
{{- if not (include "cloudbees-core.needs-routes" .) -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.is-openshift" -}}
{{- if or (has .Values.OperationsCenter.Platform (list "openshift" "openshift4")) (.Capabilities.APIVersions.Has "route.openshift.io/v1") -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.is-openshift-4" -}}
{{- if or (eq .Values.OperationsCenter.Platform "openshift4") (.Capabilities.APIVersions.Has "ingress.operator.openshift.io/v1") -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.not-openshift-4" -}}
{{- if not (include "cloudbees-core.is-openshift-4" .) -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.is-openshift-3" -}}
{{- if and (include "cloudbees-core.is-openshift" .) (include "cloudbees-core.not-openshift-4" .) -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-core.use-subdomain" -}}
{{- if and (eq (typeOf .Values.Subdomain) "bool") (eq .Values.Subdomain true) -}}
true
{{- end -}}
{{- end -}}

{{/*
Return labels, including instance and name.
*/}}
{{- define "cloudbees-core.labels" -}}
{{ include "cloudbees-core.instance-name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
helm.sh/chart: {{ include "cloudbees-core.chart" . | quote }}
{{- end -}}

{{- define "os.label" -}}
{{- if (semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion) }}kubernetes.io/os{{- else -}}beta.kubernetes.io/os{{- end -}}
{{- end -}}

{{- define "oc.protocol" -}}
{{- if or (.Values.OperationsCenter.Ingress.tls.Enable) (.Values.OperationsCenter.Route.tls.Enable) -}}https{{- else -}}{{ .Values.OperationsCenter.Protocol }}{{- end -}}
{{- end -}}

{{/*
Sanitize Operations Center context path to never have a trailing slash
*/}}
{{- define "oc.contextpath" -}}
{{- if not (empty .Values.OperationsCenter.ContextPath) -}}
{{- trimSuffix "/" .Values.OperationsCenter.ContextPath -}}
{{- else -}}
{{- if not (include "cloudbees-core.use-subdomain" .) -}}
/
{{- include "oc.name" . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "oc.ingresspath" -}}
{{- if hasPrefix "/" (include "oc.contextpath" .) -}}
{{- include "oc.contextpath" . -}}
{{- else -}}
/{{- include "oc.contextpath" . -}}
{{- end -}}
{{- end -}}

{{- define "oc.name" -}}
{{ .Values.OperationsCenter.Name }}
{{- end -}}

{{- define "oc.defaultPort" -}}
{{- if eq (include "oc.protocol" .) "https" -}}443{{- else if eq (include "oc.protocol" .) "http" -}}80{{- end -}}
{{- end -}}

{{- define "oc.port" -}}
{{- .Values.OperationsCenter.Port | default (include "oc.defaultPort" .) -}}
{{- end -}}

{{- define "oc.optionalPort" -}}
{{- if ne (include "oc.port" .) (include "oc.defaultPort" .) -}}
:{{ include "oc.port" . }}
{{- end -}}
{{- end -}}

{{/*
Expected Operations Center Hostname. Include port if not 80/443.
*/}}
{{- define "oc.hostname" -}}
{{- include "oc.hostnamewithoutport" . -}}{{- include "oc.optionalPort" . -}}
{{- end -}}

{{/*
Expected Operations Center Hostname. Include port if not 80/443.
*/}}
{{- define "oc.hostnamewithoutport" -}}
{{- if (include "cloudbees-core.use-subdomain" .)  -}}
{{- include "oc.name" . -}}.
{{- end -}}
{{- if kindIs "string" .Values.OperationsCenter.HostName -}}
{{ .Values.OperationsCenter.HostName }}
{{- end -}}
{{- end -}}

{{/*
Expected Operations Center Hostname. Include port if not 80/443.
*/}}
{{- define "hibernation.hostnamewithoutport" -}}
{{- if (include "cloudbees-core.use-subdomain" .) -}}
hibernation-{{ .Release.Namespace }}.
{{- end -}}
{{ .Values.OperationsCenter.HostName }}
{{- end -}}

{{/*
Expected Operations Center URL. Always ends with a trailing slash.
*/}}
{{- define "oc.url" -}}
{{- include "oc.protocol" . -}}://{{ include "oc.hostname" . }}{{ include "oc.contextpath" . }}/
{{- end -}}

{{- define "ingress.annotations" -}}
{{ toYaml .Values.OperationsCenter.Ingress.Annotations }}
{{- if eq .Values.OperationsCenter.Platform "eks" }}
  {{- if eq (include "oc.protocol" .) "https" }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
  {{- end }}
  {{- if not (eq (include "oc.contextpath" .) "") }}
alb.ingress.kubernetes.io/actions.root-redirect: '{"Type": "redirect", "RedirectConfig": { "Path":{{ include "ingress.root-redirect" . | quote }}, "StatusCode": "HTTP_301"}}'
  {{- end }}
alb.ingress.kubernetes.io/group.name: {{ include "cloudbees-core.fullname" .}}
alb.ingress.kubernetes.io/target-type: ip
{{- end }}
{{- if not (include "cloudbees-core.is-openshift" .) }}
nginx.ingress.kubernetes.io/ssl-redirect: "{{ .Values.OperationsCenter.Ingress.tls.Enable }}"
{{- end }}
{{- end }}

{{- define "cjoc.ingress.annotations" -}}
{{ include "ingress.annotations" . }}
{{- if eq .Values.OperationsCenter.Platform "eks" }}
alb.ingress.kubernetes.io/healthcheck-path: {{ include "oc.contextpath" . }}/login
{{- end }}
{{- if not (include "cloudbees-core.is-openshift" .) }}
nginx.ingress.kubernetes.io/app-root: {{ include "ingress.root-redirect" . | quote }}
# "413 Request Entity Too Large" uploading plugins, increase client_max_body_size
nginx.ingress.kubernetes.io/proxy-body-size: 50m
nginx.ingress.kubernetes.io/proxy-request-buffering: "off"
{{- end }}
{{- end }}

{{- define "hibernationMonitor.ingress.annotations" -}}
{{ include "ingress.annotations" . }}
{{- if eq .Values.OperationsCenter.Platform "eks" }}
alb.ingress.kubernetes.io/healthcheck-path: /health/live
{{- end }}
{{- end }}


{{- define "ingress.root-redirect" -}}
{{ include "oc.contextpath" . }}/teams-check/
{{- end }}

{{- define "ingress.redirect-rules" -}}
{{- if eq .Values.OperationsCenter.Platform "eks" }}
{{- if eq (include "oc.protocol" .) "https" }}
- path: /*
  backend:
    service:
      name: ssl-redirect
      port:
        name: use-annotation
  pathType: ImplementationSpecific
{{- end -}}
{{- if not (eq (include "oc.contextpath" .) "") }}
- path: /
  pathType: ImplementationSpecific
  backend:
    service:
      name: root-redirect
      port: 
        name: use-annotation
{{- end -}}
{{- end -}}
{{- end }}

{{/*
If rbac.installCluster is defined, honor it.
Otherwise, default to true, except on Openshift 3 where we default to "" (falsy)
*/}}
{{- define "rbac.install-cluster" -}}
{{- if eq (typeOf .Values.rbac.installCluster) "bool" -}}
{{- if eq .Values.rbac.installCluster true -}}
true
{{- end -}}
{{- else if not (include "cloudbees-core.is-openshift-3" .) -}}
true
{{- end -}}
{{- end -}}

{{- define "psp.enabled" -}}
{{- if and .Values.PodSecurityPolicy.Enabled -}}
{{- if not .Values.rbac.install -}}
{{ fail "\n\nERROR: Setting PodSecurityPolicy.Enabled=true requires rbac.install=true" }}
{{- else if not (include "rbac.install-cluster" .) -}}
{{ fail "\n\nERROR: Setting PodSecurityPolicy.Enabled=true requires rbac.installCluster=true" }}
{{- else -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "validate.operationscenter" -}}
{{- if and (.Values.OperationsCenter.Enabled) (.Values.Master.OperationsCenterNamespace) -}}
{{ fail "Can't use both OperationsCenter.Enabled=true and Master.OperationsCenterNamespace" }}
{{- end -}}
{{- end -}}

{{/*
 fsGroup defaults to 1000 (default image UID)
 * on OpenShift it defaults to unset
 * if runAsUser is 0 it defaults to unset
*/}}
{{- define "oc.fsGroup" -}}
{{- default (include "oc.defaultFsGroup" .) .Values.OperationsCenter.FsGroup -}}
{{- end -}}

{{- define "oc.defaultFsGroup" -}}
{{- if and (not (eq (toString .Values.OperationsCenter.RunAsUser) "0")) (not (include "cloudbees-core.is-openshift" .)) -}}
1000
{{- end -}}
{{- end -}}

{{/*
Pod selectors for network monitor spec
*/}}

{{- define "operationsCenter.podSelector" -}}
podSelector:
  matchLabels:
    app.kubernetes.io/instance: {{ .Release.Name | quote }}
    app.kubernetes.io/component: cjoc
{{- end -}}

{{- define "agent.podSelector" -}}
podSelector:
  matchLabels:
    jenkins: slave
{{- end -}}

{{- define "master.podSelector" -}}
podSelector:
  matchLabels:
    com.cloudbees.cje.type: master
{{- end -}}

{{- define "hibernationMonitor.podSelector" -}}
podSelector:
  matchLabels:
    app: managed-master-hibernation-monitor
    app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Plural versions for usage in network policy ingress rules
*/}}

{{- define "agent.podSelectors" -}}
{{ include "agent.podSelector" . | indent 2 | trim | printf "- %s"}}
{{- if .Values.Agents.SeparateNamespace.Enabled }}
  namespaceSelector:
    matchLabels:
      cloudbees.com/role: agents
{{- end -}}
{{- end -}}

{{- define "master.podSelectors" -}}
{{ include "master.podSelector" . | indent 2 | trim | printf "- %s"}}
{{- end -}}

{{- define "hibernationMonitor.podSelectors" -}}
{{ include "hibernationMonitor.podSelector" . | indent 2 | trim | printf "- %s"}}
{{- end -}}

{{- define "ingress.podSelectors" -}}
{{- if include "cloudbees-core.is-openshift-4" . -}}
- namespaceSelector:
    matchLabels:
      network.openshift.io/policy-group: ingress
{{- else if (not (include "cloudbees-core.is-openshift" .)) -}}
{{ include "nginxingress.podSelectors" . }}
{{- end -}}
{{- end -}}

{{- define "ingress.name" -}}
ingress-nginx
{{- end -}}

{{- define "nginxingress.podSelectors" -}}
{{- if (index .Values "ingress-nginx" "Enabled") }}
- podSelector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/component: controller
{{- else if .Values.NetworkPolicy.ingressControllerSelector }}
{{ toYaml .Values.NetworkPolicy.ingressControllerSelector -}}
{{- else }}
- namespaceSelector:
    matchLabels:
      name: {{ include "ingress.name" . }}
  podSelector:
    matchLabels:
      app: {{ include "ingress.name" . }}
      component: controller
- namespaceSelector:
    matchLabels:
      name: ingress-nginx
  podSelector:
    matchLabels:
      app: {{ include "ingress.name" . }}
      component: controller
- namespaceSelector:
    matchLabels:
      name: ingress-nginx
  podSelector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/component: controller
{{- end }}
{{- end -}}

{{- define "networkpolicy.cjoc.http" -}}
{{- if include "cloudbees-core.is-openshift" . -}}
{{ .Values.OperationsCenter.ContainerPort }}
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "networkpolicy.hibernationmonitor.http" -}}
{{- if include "cloudbees-core.is-openshift" . -}}
8090
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "networkpolicy.cjoc.agentListener" -}}
{{- if include "cloudbees-core.is-openshift" . -}}
{{ .Values.OperationsCenter.AgentListenerPort }}
{{- else -}}
jnlp
{{- end -}}
{{- end -}}

{{- define "networkpolicy.cjoc.jmx" -}}
{{- if include "cloudbees-core.is-openshift" . -}}
{{ .Values.OperationsCenter.JMXPort }}
{{- else -}}
jmx
{{- end -}}
{{- end -}}

{{- define "persistence.storageclass" -}}
{{/* Separate if blocks because go template doesn't evaluate 'and' clause lazily */}}
{{- if typeIs "string" .Values.Persistence.StorageClass -}}
{{- if ne "-" .Values.Persistence.StorageClass -}}
{{ .Values.Persistence.StorageClass}}
{{- end -}}
{{- else if (include "gke.storageclass.name" .) -}}
{{ include "gke.storageclass.name" . }}
{{- else if (include "aks.storageclass.name" .) -}}
{{ include "aks.storageclass.name" . }}
{{- end -}}
{{- end -}}

{{- define "gke.storageclass.name" -}}
{{- if eq "gke" .Values.OperationsCenter.Platform -}}
ssd-{{ .Release.Name }}-{{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{/*
Always use managed-premium storage class when running on AKS
*/}}
{{- define "aks.storageclass.name" -}}
{{- if eq "aks" .Values.OperationsCenter.Platform -}}
managed-premium
{{- end -}}
{{- end -}}

{{- define "openshift.tls" -}}
{{- if .Values.OperationsCenter.Route.tls.Enable -}}
tls:
  insecureEdgeTerminationPolicy: {{ .Values.OperationsCenter.Route.tls.InsecureEdgeTerminationPolicy }}
  termination: {{ .Values.OperationsCenter.Route.tls.Termination }}
{{- if .Values.OperationsCenter.Route.tls.CACertificate }}
  caCertificate: |-
{{ .Values.OperationsCenter.Route.tls.CACertificate | indent 4 }}
{{- end }}
{{- if .Values.OperationsCenter.Route.tls.Certificate }}
  certificate: |-
{{ .Values.OperationsCenter.Route.tls.Certificate | indent 4 }}
{{- end }}
{{- if .Values.OperationsCenter.Route.tls.Key }}
  key: |-
{{ .Values.OperationsCenter.Route.tls.Key | indent 4 }}
{{- end }}
{{- if .Values.OperationsCenter.Route.tls.DestinationCACertificate }}
  destinationCACertificate: |-
{{ .Values.OperationsCenter.Route.tls.DestinationCACertificate | indent 4}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Workaround https://github.com/openshift/origin/issues/24060
*/}}
{{- define "chart.helmRouteFix" -}}
status:
  ingress:
    - host: ""
{{- end -}}

{{- define "agents.namespace" -}}
{{- if .Values.Agents.SeparateNamespace.Enabled -}}
{{ default (printf "%s-%s" .Release.Namespace "builds") .Values.Agents.SeparateNamespace.Name }}
{{- else -}}
{{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{- define "ingress.check" -}}
{{- if not (.Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress") }}
  {{ fail "\n\nERROR: Kubernetes 1.19 or later is required to use Ingress in networking.k8s.io/v1\nIf you are using Helm template add \"--api-versions networking.k8s.io/v1/Ingress\" to the command" }}
{{- end -}}
{{- end -}}

{{- define "features.enableServiceLinks-available" -}}
{{- if semverCompare ">=1.13.0-0" .Capabilities.KubeVersion.Version -}}
true
{{- end -}}
{{- end -}}

{{- define "hibernation.routenonnamespacedurls" -}}
{{- if and (eq (typeOf .Values.OperationsCenter.Enabled) "bool") (eq .Values.OperationsCenter.Enabled false) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
