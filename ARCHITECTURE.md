



# EKS cluster

  - OIDC endpoint

## Integrations

* EBS CSI driver
* AWS Load-balancer controller (ALB)
* external-dns controller (route53)
* AWS Secrets Manager CSI driver
* Cert Issuer
* Cloudbees Sidecar Injector
* Snapshot Controller
* Datadog
* Filebeat

## Environments

* dev
* staging
* production
* fr

# Cloudbees Operations Center

## Prerequisites

### Secrets

The operations center helm deployment has additional volumes that depend on the AWS SecretsManager CSI driver.  The secretproviderclass definition (`cloudbees-dev-oc`) describes each secret that will be available for the OC to mount.  

#### cd/cloudbees/cjoc/dev/cloudbees-token

This can be empty initially since it is used to store a cloudbees API token for use by jobs created on the Operations Center.

#### cd/cloudbees/cjoc/dev/eks-dev-credentials

This stores a kubeconfig generated for the `cjoc` service account on the dev EKS cluster.  It is used for a custom kubernets provisioner endpoint to deploy controllers in a different namespace.  This is no longer used since there were some unresolved issues with controllers using this.

#### cd/cloudbees/cjoc/dev/gerrit-creds

Store the gerrit ssh key.

#### cd/cloudbees/cjoc/dev/git-credentials

The ssh key generated for the user that is used for most job git cloning.

#### cd/cloudbees/cjoc/dev/github-token

The GitHub API token generated for the user that is used for most jobs git cloning.

#### cd/cloudbees/cjoc/dev/instance_id

Stores the instance_id for the Operations Center, which is used when issuing the license.  You should allow the OC to generate a new instance id and then save it.  This was intended to help with making the OC reproducible but otherwise you can just rely on backups of the volume.

#### cd/cloudbees/cjoc/dev/secret_key

Stores the master secret key for the Operations Center.  You should allow the OC to generate a new secret key and then save it.  This was intended to help with making the OC reproducible but otherwise you can just rely on backups of the volume.

#### cd/cloudbees/cjoc/dev/secrets.properties

The `secrets.properties` file is loaded by jenkins from the local filesystem.  It contains the following key/value format.  The keys are made available as variables in jenkins and in the jenkins CasC.  We use the following variables in our CasC files.  The values are stored in secrets manager (cd/cloudbees/cjoc/dev/secrets.properties) and mounted throught the AWS secretsmanager CSI driver so that can be made availble in the cjoc pod at `/run/secrets/secrets.properties`.  Most of the values are used to configure the client controller for the given environment.  For example CI_ENVIRONMENT, domain_name and most other environment-specific values are always set here to ensure the CasC is the same between environments.  This also allows environment-specific customization, for instance setting ingress_class to a different ingress controller type.


    CI_ENVIRONMENT = dev

    CONTROLLER_MEMORY = 3072

    CONTROLLER_CPUS = 1.0

    SM_CREDENTIALS_PATH = cd/cloudbees/dev

    CONFIG_VALUES_PATH = cd/cloudbees/dev

    LB_CD_CERTIFICATE_ARN = arn:aws:acm:us-west-2:XXXXXXXXXXXX:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

    LB_CERTIFICATE_ARN = arn:aws:acm:us-west-2:XXXXXXXXXXXX:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

    SECRETS_ROLE_ARN = arn:aws:iam::XXXXXXXXXXXX:role/eks-iam-cloudbees-dev-jenkins-secrets

    SSE_SECRETS_ROLE_ARN = arn:aws:iam::XXXXXXXXXXXX:role/eks-iam-cloudbees-dev-jenkins-secrets

    SECRET_ACCOUNT_ID = XXXXXXXXXXX

    saml_sp_entity_id = cloudbees-dev

    saml_idp_metadata_url = https://fsecure.okta.com/app/fsecure-prod_cloudbeesjenkinsdevelopment_1/XXXXXXXXXXX/sso/saml

    saml_idp_metadata = <?xml version="1.0" encoding="UTF-8"?><md:EntityDescriptor entityID="http://www.okta.com/XXXXXXXXXXXXX" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"><md:IDPSSODescriptor WantAuthnRequestsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"><md:KeyDescriptor use="signing"><ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:X509Data><ds:X509Certificate>MIIXXXXXXXXXXXXXXXXXXXXXXX\
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\
    ...
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX==</ds:X509Certificate></ds:X509Data></ds:KeyInfo></md:KeyDescriptor><md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat><md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat><md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://fsecure.okta.com/app/fsecure_cloudbeesjenkinsdevelopment_1/XXXXXXXXXXXXXXX/sso/saml"/><md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://fsecure.okta.com/app/fsecure_cloudbeesjenkinsdevelopment_1/XXXXXXXXXXXXXX/sso/saml"/></md:IDPSSODescriptor></md:EntityDescriptor>

    KUBERNETES_NAMESPACE = cloudbees-dev

    domain_name = cloudbees.dev.fsecure.com

    oc_url = https://cjoc.cloudbees.dev.fsecure.com/

    use_subdomain = true

    ingress_class = alb

    jenkins_url = http://cjoc.cloudbees-dev.svc.cluster.local/

    license_key = -----BEGIN RSA PRIVATE KEY-----\n\
    MIIXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    ...
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=\n\
    -----END RSA PRIVATE KEY-----

    license_cert = -----BEGIN CERTIFICATE-----\n\
    MIIXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    ...
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\
    -----END CERTIFICATE-----

    github_app_key = {AQXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}


## Deployment

![OC Deployment](md-images/cloudbees-operations-center.png)


## Helm Chart

The Cloudbees helm charts create the Kubernetes resources for the deployment of the operations center.  These resources depend on the listed add-ons and integrations to provide the required AWS resources such as DNS records, load balancers and EBS storage volumes.

- ingress (ALB, ACM Certificate)
- StatefulSet (EBS PV, SecretManager)
- Service Accounts
  - cjoc (IAM role)
  - jenkin (IAM role)
  - jenkins-agents

## Storage

All Cloudbees pods are deployed using a StatefulSet resource.  The StatefulSet requires a physical volume (PV) definition to preserve the state of the Jenkins home directory volume.  For EKS we use the EBS CSI driver to provision an EBS volume for each controller.



## DNS

Cloudbees DNS records can be managed in two ways:

### Dynamically Created Sub-domains

In the helm chart values.yaml you will need to set the subdomain feature as well as the OC HostName to the name of the Zone in which records will be created using the external-dns controller.  These settings will also be defined in the OC CasC `globalJavaOptions`.

    Subdomain: true
    OperationsCenter:
      HostName: cloudbees.dev.flexilis.com

#### External DNS

The external-dns controller provides access to a Route53 zone in which it will create DNS records for each ingress definition.  The Cloudbees OC will create each controller with an ingress configured with the unique hostname set for the controller.

##### Route53 Zone

If the OC is configured for use with the `subdomain` feature it will generate each controller URL using a unique subdomain of the provided zone.

    cloudbees.dev.flexilis.com

Where the controller name is `cd`:

    ingress: cd

        hostname: cd.cloudbees.dev.flexilis.com

### Single Static DNS Records

Hosting Cloudbees on a single domain will mean that all controllers will use the Hostname defined for the operations centers and each controller will be accessed using a sub-path.  E.g. the `cd` controller https://cloudbees-static.dev.flexilis.com/cd/

## Secrets

The Cloudbees Operations Center and Client Controllers use the AWS Secrets Manager CSI driver to make AWS SM Secrets available as volumes mounted in the pod (described by the [SecretProviderClass](#secretproviderclass)).  These secrets can then be exposed in the Jenkins credential store by defining secrets in the CasC configuration that read their values from these volumes mounted in the pod.  Most secrets in the Jenkins credential store, however, are loaded using the AWS Secrets Manager Provider (aws-secrets-manager-credentials-provider) plugin.  The plugin assumes the secrets role "eks-iam-cloudbees-${var.env}-${var.name}-secrets" to expose SecretsManager secrets throught the Jenkins credential store, for each controller, automatically.

![Client Controller Secrets](md-images/cloudbees-controller-secrets.png)
*Client Controller Secrets*

### KMS Key

A KMS key is created for each controller in the secrets account, for use by the secrets role created for each controller.

### IAM Role

A secrets role is created in the secrets account that is used by the controller to map secrets into the Jenkins credentials store.  The role has a trust relationship with the role assigned to the service account used by each controller.
This allows the aws-secrets-manager-credentials-provider plugin to assume the role and load the secrets available for the controller.  The role is granted access to secrets with names matching the following pattern.  These secrets are private to the given controller:

    cd/cloudbees/${controller_name}/${environment}/...



### SecretProviderClass

The Operations Center has a SecretProviderClass resource defined which contains a map of secrets which can be exposed as volume mounts.

[Terraform Module](terraform/modules/cloudbees_secrets_store/main.tf#L15)

The generated SecretProviderClass manifest is referenced by the container spec in the Cloudbees Helm charts and also the client controller definitions.

    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: cloudbees-dev-oc
      namespace: cloudbees-dev
    spec:
      parameters:
        objects: |
          - "objectAlias": "eks-sse-credentials"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/eks-sse-credentials"
            "objectType": "secretsmanager"
          - "objectAlias": "eks-fr-credentials"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/eks-dev-credentials"
            "objectType": "secretsmanager"
          - "objectAlias": "cloudbees-token"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/cloudbees-token"
            "objectType": "secretsmanager"
          - "objectAlias": "github-token"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/github-token"
            "objectType": "secretsmanager"
          - "objectAlias": "secret_key"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/secret_key"
            "objectType": "secretsmanager"
          - "objectAlias": "instance_id"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/instance_id"
            "objectType": "secretsmanager"
          - "objectAlias": "secrets-properties"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/secrets.properties"
            "objectType": "secretsmanager"
          - "objectAlias": "gerrit-creds"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/gerrit-creds"
            "objectType": "secretsmanager"
          - "objectAlias": "git-credentials"
            "objectName": "arn:aws:secretsmanager:us-west-2:XXXXXXXXXXXX:secret:cd/cloudbees/cjoc/dev/git-credentials"
            "objectType": "secretsmanager"
      provider: aws


### Volumes

In the Cloudbees Helm chart we define extra volumes to mount the secret provided by the `secrets-store.csi.k8s.io` driver referencing the `secretProviderClass: "cloudbees-dev-oc"`

    ExtraVolumes:
      - name: gerrit-creds
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "cloudbees-dev-oc"
      - name: secrets-key
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "cloudbees-dev-oc"
      - name: secrets-properties
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "cloudbees-dev-oc"
    ExtraVolumeMounts:
      - name: gerrit-creds
        mountPath: /var/jenkins_home/.ssh/id_rsa
        subPath: gerrit-creds
        readOnly: true
      - name: secrets-key
        mountPath: /var/jenkins_home/secret.key
        subPath: secret_key
        readOnly: true
      - name: secrets-properties
        mountPath: /run/secrets/secrets.properties
        subPath: secrets-properties
        readOnly: true



# Client Controller

## Deployment

![Client Controller Deployment](md-images/cloudbees-client-controller.png)
