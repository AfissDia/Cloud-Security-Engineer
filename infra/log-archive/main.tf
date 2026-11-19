# Projet 7 - DataHelix
# Stockage centralise des journaux de securite

# 1. Bucket S3 dans LOG-ARCHIVE

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "datahelix-log-archive-110696054523"

  tags = {
    Project     = "DataHelix"
    Environment = "LOG-ARCHIVE"
    Purpose     = "SecurityLogs"
    ManagedBy   = "OpenTofu"
  }
}

# 2. Activation du versioning

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Configuration du chiffrement SSE-S3

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Blocage des acces publics

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
