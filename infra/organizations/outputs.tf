output "workloads_ou_id" {
  value = aws_organizations_organizational_unit.workloads.id
}

output "security_ou_id" {
  value = aws_organizations_organizational_unit.security.id
}

output "datahelix_accounts" {
  description = "Identifiants des comptes DataHelix"

  value = {
    for name, account in aws_organizations_account.datahelix :
    name => account.id
  }
}

