data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "provider" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

locals {
  namespace                       = (var.namespace == "" ? "cloudbees-${var.env}" : "${var.namespace}")
}

resource "aws_iam_role" "service_account" {
  name = "eks-iam-cloudbees-${var.env}-${var.name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${data.aws_iam_openid_connect_provider.provider.arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${replace(data.aws_iam_openid_connect_provider.provider.url, "https://", "")}:sub": "system:serviceaccount:${local.namespace}:${var.name}",
                    "${replace(data.aws_iam_openid_connect_provider.provider.url, "https://", "")}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attached" {
  count      = length(var.policies)
  role       = aws_iam_role.service_account.name
  policy_arn = var.policies[count.index]
}


resource "kubernetes_manifest" "service_account" {
  manifest      = {
    apiVersion  = "v1"
    kind        = "ServiceAccount"
    metadata    = {
      name      = var.name
      namespace = local.namespace
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.service_account.arn
      }
    }
    automountServiceAccountToken = var.automount_service_account_token
    secrets = var.secret ? [{ name = kubernetes_secret.token[0].metadata.0.name }] : null
  }
}

resource "kubernetes_secret" "token" {
  count         = var.secret ? 1 : 0
  metadata {
    name          = "${var.name}-token${var.token_suffix}"
    namespace     = local.namespace
    annotations   = {
      "kubernetes.io/service-account.name" = "${var.name}"
    }
  }
  type          = "kubernetes.io/service-account-token"
}

resource "kubernetes_role_binding" "rolebinding" {
  count       = var.rolebinding ? 1 : 0
  metadata {
    name      = "cjoc-master-role-binding-${var.name}"
    namespace = local.namespace
    labels    = {
      "app.kubernetes.io/instance" = "lookout"
      "app.kubernetes.io/name" = "cloudbees-core"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cjoc-agents"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = local.namespace
  }
}


resource "kubernetes_cluster_role_binding" "management_rolebinding" {
  count       = var.name == "cjoc" ? 1 : 0
  metadata {
    name      = "cjoc-role-binding-cloudbees-${var.env}-${var.name}"
    labels    = {
      "app.kubernetes.io/instance" = "lookout"
      "app.kubernetes.io/name" = "cloudbees-core"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cjoc-master-management-cloudbees-${var.env}"
  }
  subject {
    kind = "ServiceAccount"
    name = var.name
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "master_rolebinding" {
  count       = var.name == "cjoc" ? 1 : 0
  metadata {
    name      = "cjoc-role-binding-${var.env}"
    namespace = local.namespace
    labels    = {
      "app.kubernetes.io/instance" = "lookout"
      "app.kubernetes.io/name" = "cloudbees-core"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cjoc-master-management"
  }
  subject {
    kind = "ServiceAccount"
    name = var.name
  }
}
