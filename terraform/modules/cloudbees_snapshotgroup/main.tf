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
  class_name = "cloudbees-pvc-backup-${var.env}-${var.name}"
}

resource "kubernetes_manifest" "snapshot_group" {
  manifest = {
    apiVersion = "gemini.fairwinds.com/v1beta1"
    kind       = "SnapshotGroup"
    metadata = {
      namespace = local.namespace
      name      = local.class_name
    }
    spec = {
      template = {
        spec = {
#          volumeSnapshotClassName = "csi-aws-vsc-cloudbees-${var.env}"
        }
      }
      persistentVolumeClaim = {
        claimName = "jenkins-home-${var.name}-0"
      }
      schedule = [
      {
        every = "30 minutes"
        keep  = 2
      },
      {
        every = "day"
        keep = var.keep
      },
      {
        every = "month"
        keep  = 1
      }
      ]
    }
  }
}
