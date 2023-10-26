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
  tags       = merge(var.tags, { "snapshotname" = "{{ .VolumeSnapshotName }}" })
}

resource "kubernetes_namespace" "controllers" {
  metadata {
    labels = {
      sidecar-injector = "enabled"
    }

    name = local.namespace
  }
}

resource "kubernetes_config_map" "ca-bundles" {
  metadata {
    namespace = local.namespace
    name      = "ca-bundles"
  }

  data = {
    for f in fileset(var.certs_dir, "*.crt") :
    f => file(join("/", [var.certs_dir, f]))
  }
  binary_data = {
    for f in fileset(var.certs_dir, "cacerts") :
    f => filebase64(join("/", [var.certs_dir, f]))
  }
}

resource "kubernetes_storage_class" "ebs_storage_class" {
  metadata {
    name   = "ebs-sc"
    labels = {
      "k8slens-edit-resource-version" = "v1"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

#resource "kubernetes_manifest" "ebs_volume_snapshot_class" {
#  manifest = {
#    apiVersion     = "snapshot.storage.k8s.io/v1"
#    deletionPolicy = "Delete"
#    driver         = "ebs.csi.aws.com"
#    kind           = "VolumeSnapshotClass"
#    metadata       = {
#      annotations  = {
#        "snapshot.storage.kubernetes.io/is-default-class" = "true"
#      }
#      name         = "csi-aws-vsc-cloudbees-${var.env}"
#    }
#    parameters     = {
#      for index, key in keys(local.tags) : "tagSpecification_${index + 1}" => "${key}=${local.tags[key]}"
#    }
#  }
#}
