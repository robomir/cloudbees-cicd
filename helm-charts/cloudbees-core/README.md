# cloudbees-core

![Version: 3.42.6](https://img.shields.io/badge/Version-3.42.6-informational?style=flat-square) ![AppVersion: 2.332.2.6](https://img.shields.io/badge/AppVersion-2.332.2.6-informational?style=flat-square)

[CloudBees CI](https://www.cloudbees.com/products/continuous-integration) is the continuous integration platform architected for the enterprise. It provides:

* DevOps at scale
* Resilience and high availability
* Easy management
* Enterprise grade security

## TL;DR;

```console
$ helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
$ helm install cloudbees/cloudbees-core --name <release name>
```

## Introduction

This chart bootstraps a CloudBees CI deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
  - Kubernetes 1.14 or higher
  - Helm 3.0.2 or higher

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.cloudbees.com/public/cloudbees | cloudbees-sidecar-injector | 2.2.1 |
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | 4.0.13 |

## Installing the Chart

### Default installation

This installs the chart with the release name `cloudbees-core` and hostname `cloudbees-core.example.com`.
When installing this chart on a Kubernetes cluster, an ingress controller must be set up.

The chart can install the NGINX Ingress Controller for you. This installation is described in the next section.

```console
$ helm install cloudbees/cloudbees-core \
       --name cloudbees-core \
       --set OperationsCenter.HostName='cloudbees-core.example.com'
```

The command deploys CloudBees CI on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

### Ingress Controller Installation

The chart is designed, so it can install an ingress-nginx controller.
The `"ingress-nginx".Enabled` field controls ingress controller installation and setup.
To install the chart with the release name `cloudbees-core` and hostname cloudbees-core.example.com.

```console
$ helm install cloudbees/cloudbees-core \
       --name cloudbees-core \
       --set "ingress-nginx".Enabled=true
```

## Uninstalling the Chart

To uninstall/delete the `cloudbees-core` deployment:

```console
$ helm delete cloudbees-core
```
> **NOTE**: The current version of the CloudBees CI Helm Chart only manages the Operation Center.
Users should manage Managed Controllers using Operation Center.

The `helm delete` command stops the CloudBees CI deployment than removes the OperationsCenter Center.
The release is still stored in the Helm database, but it will now have the status deleted.
If you wish to completely remove the release, use the following variation of the `helm delete` command.

```console
$ helm delete cloudbees-core --purge
```

> **IMPORTANT**: The `helm delete` command does NOT remove the persistent volume claims as precaution against data loss.
You will need to use the `kubectl delete pvc` command to delete the persistent volume claims.

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Please refer to the chart `values.yaml` to get the exhaustive list of values that can be customized.
The easiest way to consult it is through the command `helm inspect values cloudbees/cloudbees-core`.

Each property can override a default value with a value that specific to your Kubernetes cluster
You can provide this values using the `--set` flag on the Helm command line.

Helm also support merging values files together, so that you can create a YAML file for each environment.

### Environment Property Value Files
Helm provides the option to use a custom property values file to override the default values set in the `values.yaml` file.
CloudBees recommends creating a custom properties file to override the default for your environments, instead of directly editing the included values.yaml file.

To use an environment property value file with Helm, use the -f option as shown in the following example:
`helm install cloudbees-core --name cloudbees-core -f example-values.yaml`

You can download the latest version of the `example-values.yaml` file from CloudBees Examples GitHub repository at https://github.com/cloudbees/cloudbees-examples/tree/master/helm-custom-value-file-examples.

## Additional Documentation
CloudBees provides complete and more detailed installation and operation documentation on the CloudBees web site at https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| Agents.Enabled | bool | `true` | Enable to create agent resources (service account, role) |
| Agents.Image.dockerImage | string | `"cloudbees/cloudbees-core-agent:2.332.2.6"` | Used to override the default docker image used for agents |
| Agents.ImagePullSecrets | string | `nil` | Name of image pull secret to pull private Docker images or an array of image pull secrets |
| Agents.SeparateNamespace.Create | bool | `false` | If true, the second namespace will be created when installing this chart. Otherwise, the existing namespace should be labeled with `cloudbees.com/role: agents` in order for network policies to work. |
| Agents.SeparateNamespace.Enabled | bool | `false` | If enabled, agents resources will be created in a separate namespace as well as bindings allowing masters to schedule them. |
| Agents.SeparateNamespace.Name | string | `nil` | Namespace where to create agents resources. Defaults to `${namespace}-builds` where `${namespace}` is the namespace where the chart is installed. |
| Hibernation.Enabled | bool | `false` | Whether to enable the [Hibernation](https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/managing-masters#_hibernation_of_managed_masters) feature |
| Hibernation.Image.dockerImage | string | `"cloudbees/managed-master-hibernation-monitor:262.5ed3e62e140f"` | Used to override the default docker image |
| Hibernation.Image.dockerPullPolicy | string | `nil` | Used to override the default pull policy |
| Hibernation.ImagePullSecrets | string | `nil` | Name of image pull secret to pull private Docker images or an array of image pull secrets |
| Hibernation.NodeSelector | object | `{}` | Node labels and tolerations for pod assignment ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector |
| Hibernation.Tolerations | list | `[]` | Specify tolerations for the Hibernation Monitor pod. See [documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| Master.Enabled | bool | `true` | Whether to create the resources required to schedule controllers. |
| Master.Image.dockerImage | string | `"cloudbees/cloudbees-core-mm:2.332.2.6"` | Used to override the default docker image |
| Master.JavaOpts | string | `nil` | Additional Java options to pass to managed controllers. For example, setting up a JMX port |
| Master.OperationsCenterNamespace | string | `nil` | When deploying Controller resources, this grants an Operations Center deployed in another namespace the right to deploy controllers |
| NetworkPolicy.Enabled | bool | `false` | Enable only if the cluster supports it. Read the [documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to understand what this is about. |
| NetworkPolicy.JMXSelectors | list | `[]` | Custom selectors for accessing JMX port |
| NetworkPolicy.ingressControllerSelector | list | `[]` | Custom selector for the ingress-controller |
| OperationsCenter.AgentListenerPort | int | `50000` | Container port for agent listener traffic |
| OperationsCenter.Annotations | object | `{}` | Additional annotations to put on the pod running Operations Center |
| OperationsCenter.CSRF.ProxyCompatibility | bool | `false` | Proxy compatibility for the default CSRF issuer |
| OperationsCenter.CasC.ConfigMapName | string | `"oc-casc-bundle"` | the name of the ConfigMap used to configure Operations Center. Note: this property can point to a ConfigMap defined in OperationsCenter.ExtraConfigMaps, or any ConfigMap that exists in the cluster. |
| OperationsCenter.CasC.Enabled | bool | `false` | enable or disable CasC for Operations Center. |
| OperationsCenter.ContainerPort | int | `8080` | Container port for http traffic |
| OperationsCenter.ContextPath | string | `nil` | the path under which Operations Center will be accessible in the given host. DEPRECATED - Use OperationsCenter.Name instead. |
| OperationsCenter.Enabled | bool | `true` | Disable for particular use case like setting up namespaces to host masters only |
| OperationsCenter.ExtraConfigMaps | list | `[]` | Extra configmaps deployed with the chart |
| OperationsCenter.ExtraContainers | list | `[]` | Extra containers to add to the pod containing Operations Center. |
| OperationsCenter.ExtraGroovyConfiguration | object | `{}` | Provides additional init groovy scripts Each key becomes a file in /var/jenkins_config |
| OperationsCenter.ExtraVolumeMounts | list | `[]` | Extra volume mounts to add to the container containing Operations Center |
| OperationsCenter.ExtraVolumes | list | `[]` | Extra volumes to add to the pod |
| OperationsCenter.HealthProbeLivenessFailureThreshold | int | `12` | Threshold for liveness failure |
| OperationsCenter.HealthProbes | bool | `true` | Enable Kubernetes Liveness and Readiness Probes |
| OperationsCenter.HostName | string | `nil` | The hostname used to access Operations Center through the ingress controller. |
| OperationsCenter.Image.dockerImage | string | `"cloudbees/cloudbees-cloud-core-oc:2.332.2.6"` | Container image to use for Operations Center |
| OperationsCenter.Image.dockerPullPolicy | string | `nil` | https://kubernetes.io/docs/concepts/containers/images/#updating-images |
| OperationsCenter.ImagePullSecrets | string | `nil` | Name of image pull secret to pull private Docker images or an array of image pull secrets |
| OperationsCenter.Ingress.Annotations | object | `{"kubernetes.io/tls-acme":"false"}` | annotations to put on Ingress object |
| OperationsCenter.Ingress.Class | string | `"nginx"` | Ingress class to use for OC and MM ingresses Should be set to the same value as nginx-ingress.controller.ingressClass if enabled |
| OperationsCenter.Ingress.tls.Enable | bool | `false` | Set this to true in order to enable TLS on the ingress record |
| OperationsCenter.Ingress.tls.SecretName | string | `nil` | The name of the secret containing the certificate and private key to terminate TLS for the ingress |
| OperationsCenter.JavaOpts | string | `nil` | Additional java options to pass to the Operations Center |
| OperationsCenter.JenkinsOpts | string | `nil` | Additional arguments for jenkins.war |
| OperationsCenter.LoadBalancerIP | string | `nil` | Optionally assign a known public LB IP |
| OperationsCenter.LoadBalancerSourceRanges | list | `["0.0.0.0/0"]` | Only applicable when using `ServiceType: LoadBalancer` |
| OperationsCenter.Name | string | `"cjoc"` | the name in the URL under which Operations Center will be accessible in the given host. For instance, if Subdomain is true, the URL to access Operations Center will be {{OperationsCenter.Protocol}}://{{OperationsCenter.Name}}.{{OperationsCenter.HostName}}:{{OperationsCenter.Port}} If Subdomain is false, the URL to access Operations Center will be {{OperationsCenter.Protocol}}://{{OperationsCenter.HostName}}:{{OperationsCenter.Port}}/{{OperationsCenter.Name}} |
| OperationsCenter.NodeSelector | object | `{}` | Node labels and tolerations for pod assignment ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector |
| OperationsCenter.Platform | string | `"standard"` | Enables specific settings depending on the platform platform specific values are: `eks`, `aws`, `gke`, `aks`, `openshift`, `openshift4` Note: `openshift` maps to OpenShift 3.x |
| OperationsCenter.Protocol | string | `"http"` | the protocol used to access CJOC. Possible values are http/https. |
| OperationsCenter.Resources.Limits.Cpu | int | `1` | CPU limit to run Operations Center https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu |
| OperationsCenter.Resources.Limits.Memory | string | `"2G"` | Memory limit to run Operations Center https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory |
| OperationsCenter.Resources.Requests.Cpu | int | `1` | CPU request to run Operations Center https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu |
| OperationsCenter.Resources.Requests.Memory | string | `"2G"` | Memory request to run Operations Center https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory |
| OperationsCenter.Route.tls.CACertificate | string | `nil` | CA Certificate PEM-encoded |
| OperationsCenter.Route.tls.Certificate | string | `nil` | Certificate PEM-encoded |
| OperationsCenter.Route.tls.DestinationCACertificate | string | `nil` | When using `termination=reencrypt`, destination CA PEM-encoded |
| OperationsCenter.Route.tls.Enable | bool | `false` | Set this to true in OpenShift to terminate TLS at route level Read https://docs.openshift.com/container-platform/4.6/networking/routes/secured-routes.html for details. These also apply to Hibernation monitor if enabled. |
| OperationsCenter.Route.tls.InsecureEdgeTerminationPolicy | string | `"Redirect"` | Whether to redirect http to https |
| OperationsCenter.Route.tls.Key | string | `nil` | Private key PEM-encoded |
| OperationsCenter.Route.tls.Termination | string | `"edge"` | Type of termination |
| OperationsCenter.ServiceAgentListenerPort | int | `50000` | Controls the service port where Operations Center TCP port for agents is exposed. Don't change this parameter unless you know what you are doing |
| OperationsCenter.ServiceAnnotations | object | `{}` | Additional annotations to put on the Operations Center service |
| OperationsCenter.ServicePort | int | `80` | Controls the service port where Operations Center http port is exposed. Don't change this parameter unless you know what you are doing |
| OperationsCenter.ServiceType | string | `"ClusterIP"` | Service Type. Defaults to ClusterIP, since we recommend using an ingress controller. |
| OperationsCenter.TmpVolumeMedium | string | `""` | Medium for the EmptyDir volume used for the TMP directory of the Operations Center |
| OperationsCenter.Tolerations | list | `[]` | Specify tolerations for the Operations Center pod. See [documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| Persistence.AccessMode | string | `"ReadWriteOnce"` | Access mode for the PVC ([doc](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)) |
| Persistence.Annotations | object | `{}` | Annotations to put on the PVC |
| Persistence.Size | string | `"20Gi"` | Size of the Operations Center volume |
| Persistence.StorageClass | string | `nil` | Persistent Volume Storage Class for Jenkins Home If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If undefined (the default) or set to null, the default storage class will be used, unless specified otherwise below. If setting OperationsCenter.Platform == gke, a storage class backed with SSD drives will be created by this chart and used automatically. |
| PodSecurityPolicy.Annotations | object | `{}` | Additional annotations to put on the PodSecurityPolicy, e.g. AppArmor/Seccomp settings |
| PodSecurityPolicy.Enabled | bool | `false` | Enables [Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) support Enable only if the cluster supports it. |
| Subdomain | bool | `false` | Whether to use a DNS subdomain for each controller. |
| ingress-nginx.Enabled | bool | `false` | Installs the [ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) controller (optional). Enable this section if you don't have an existing installation of ingress-nginx controller Note: use `beta.kubernetes.io/os` when deploying on Kubernetes versions below 1.16 |
| ingress-nginx.controller.admissionWebhooks.patch.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| ingress-nginx.controller.allowSnippetAnnotations | bool | `false` |  |
| ingress-nginx.controller.ingressClass | string | `"nginx"` |  |
| ingress-nginx.controller.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| ingress-nginx.controller.service.externalTrafficPolicy | string | `"Local"` |  |
| ingress-nginx.defaultBackend.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| rbac.agentServiceAccountAnnotations | object | `{}` |  |
| rbac.agentsServiceAccountName | string | `"jenkins-agents"` |  |
| rbac.hibernationMonitorServiceAccountName | string | `"managed-master-hibernation-monitor"` | Name of the service account the Hibernation monitor will run as (if enabled) |
| rbac.install | bool | `true` | Install `role`/`rolebindings`/`serviceAccount`. If false (and rbac is enabled in the cluster anyway), provide valid names for all service accounts. |
| rbac.masterServiceAccountAnnotations | object | `{}` |  |
| rbac.masterServiceAccountName | string | `"jenkins"` | Name of the service account Jenkins masters will run as |
| rbac.serviceAccountAnnotations | object | `{}` |  |
| rbac.serviceAccountName | string | `"cjoc"` | Name of the service account Operations Center will run as |
| sidecarinjector.Enabled | bool | `false` | Whether to enable installation of Sidecar Injector |
