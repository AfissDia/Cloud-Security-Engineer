provider "aws" {
  region = "eu-west-3"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    iam = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}
