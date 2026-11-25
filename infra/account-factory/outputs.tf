output "account_id" {
  value = aws_organizations_account.development.id
  description = "Identifiant du compte créé."
}

output "account_arn" {
  value = aws_organizations_account.development.arn
}
