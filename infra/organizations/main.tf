variable "root_id" {
  description = "Identifiant de la racine AWS Organizations"
  type        = string
  default     = "r-5d9efe"
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = var.root_id
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = var.root_id
}

locals {
  accounts = {
    prod = {
      name  = "PROD"
      ou_id = aws_organizations_organizational_unit.workloads.id
    }

    staging = {
      name  = "STAGING"
      ou_id = aws_organizations_organizational_unit.workloads.id
    }

    dev = {
      name  = "DEV"
      ou_id = aws_organizations_organizational_unit.workloads.id
    }

    security = {
      name  = "SECURITY"
      ou_id = aws_organizations_organizational_unit.security.id
    }

    log-archive = {
      name  = "LOG-ARCHIVE"
      ou_id = aws_organizations_organizational_unit.security.id
    }
  }
}

resource "aws_organizations_account" "datahelix" {
  for_each = local.accounts

  name      = each.value.name
  email     = "${each.key}@datahelix.example"
  parent_id = each.value.ou_id

  close_on_deletion = false

  tags = {
    Project     = "DataHelix"
    Environment = each.key
    ManagedBy   = "OpenTofu"
  }
}

