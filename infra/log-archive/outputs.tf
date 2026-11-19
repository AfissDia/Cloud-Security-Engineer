output "log_bucket_name" {
  description = "Nom du bucket central des journaux"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "log_bucket_arn" {
  description = "ARN du bucket de journalisation"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}
