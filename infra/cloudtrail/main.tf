resource "aws_cloudtrail" "organization" {
  name           = "DataHelix-Organization-Trail"
  s3_bucket_name = "datahelix-log-archive-888031631734"
  s3_key_prefix  = "cloudtrail"

  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true

  tags = {
    Project     = "DataHelix"
    Environment = "Security"
    ManagedBy   = "OpenTofu"
  }
}
