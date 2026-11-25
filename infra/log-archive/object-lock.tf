# Protection des journaux DataHelix
# Rétention en mode Governance pendant 7 jours

resource "aws_s3_bucket_object_lock_configuration" "log_protection" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 7
    }
  }
}
