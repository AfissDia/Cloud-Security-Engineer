terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_organizations_account" "development" {
  name      = var.account_name
  email     = var.account_email
  parent_id = var.parent_id
  tags      = merge(var.tags, { Environment = "dev", ManagedBy = "OpenTofu" })
  lifecycle {
    prevent_destroy = true
  }
}
