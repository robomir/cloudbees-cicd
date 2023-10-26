terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.5.0"
    }
  }
}

locals {
  namespace  = (var.namespace == "" ? "cloudbees-${var.env}" : "${var.namespace}")
  class_name = "cloudbees-${var.env}-${var.name}"
}

resource "kubernetes_manifest" "secret-provider-class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      namespace = local.namespace
      name      = local.class_name
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          for secret in var.secrets : {
            objectName  = secret
            objectType  = "secretsmanager"
            objectAlias = replace(element(split("/", secret), length(split("/", secret)) - 1), ".", "-")
          }
        ])
      }
    }
  }
}
