output "security_audit_role_arn" {
  description = "ARN du role d'audit du compte DEV"
  value       = aws_iam_role.security_audit.arn
}

output "security_audit_role_name" {
  description = "Nom du role IAM"
  value       = aws_iam_role.security_audit.name
}
