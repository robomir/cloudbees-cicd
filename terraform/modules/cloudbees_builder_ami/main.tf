locals {
  builder_distributions = length(var.builder_distributions) > 0 ? var.builder_distributions : {
    "ubuntu18/arm64" = { "dist" = "bionic", "arch" = "arm64" }
    "ubuntu18/amd64" = { "dist" = "bionic", "arch" = "x86_64" }
    "ubuntu20/arm64" = { "dist" = "focal", "arch" = "arm64" }
    "ubuntu20/amd64" = { "dist" = "focal", "arch" = "x86_64" }
  }
  controller_path    = length(var.controller_name) == 0 ? "" : "${var.controller_name}/"
  controller_tag     = length(var.controller_name) == 0 ? "all" : "controller:${var.controller_name}:"
}

data "aws_ami" "builder_ami" {
  provider    = aws
  for_each    = local.builder_distributions

  most_recent = true

  filter {
    name      = "name"
    values    = ["${var.builder_ami_name}-*-${each.value.dist}"]
  }

  filter {
    name      = "architecture"
    values    = [each.value.arch]
  }

  owners      = [ var.owners ]
}

resource "aws_secretsmanager_secret" "ami" {
  provider    = aws
  name        = "cd/cloudbees/${local.controller_path}${var.env}/${var.name}"
  description = "cd/cloudbees/${local.controller_path}${var.env}/${var.name}"
  kms_key_id  = var.kms_key_id

  tags        = merge({
    product                  = "cd"
    service                  = "cloudbees"
    environment              = var.env
  }, merge({"cloudbees:controller:name" = "${local.controller_tag}"}, var.tags))
}

resource "aws_secretsmanager_secret_version" "ami" {
  provider      = aws
  secret_id     = aws_secretsmanager_secret.ami.id
  secret_string = jsonencode({
    for k,v in local.builder_distributions: "${k}/ami" => data.aws_ami.builder_ami[k].id
  })
}

