output "vpc_ids" {
  value = {
    prod    = module.prod.vpc_id
    staging = module.staging.vpc_id
    dev     = module.dev.vpc_id
  }
}

output "subnet_ids" {
  value = {
    prod    = module.prod.subnet_id
    staging = module.staging.subnet_id
    dev     = module.dev.subnet_id
  }
}

output "security_group_ids" {
  value = {
    prod    = module.prod.security_group_id
    staging = module.staging.security_group_id
    dev     = module.dev.security_group_id
  }
}
