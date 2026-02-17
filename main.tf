locals {
  locations       = [for loc in var.locations : merge(loc, { type = "aws" })]
  private-package = var.private-package != null ? merge(var.private-package, { type = "aws" }) : null

  git = {
    ssh_enabled   = length(var.git.ssh.private-key-secret-arn) > 0
    creds_enabled = length(var.git.credentials.token-secret-arn) > 0
  }
}

data "aws_region" "current" {}
