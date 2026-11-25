# MiniStack - Projet DataHelix

provider "aws" {
  alias      = "prod"
  region     = "eu-west-3"
  access_key = "431122467493"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}

provider "aws" {
  alias      = "staging"
  region     = "eu-west-3"
  access_key = "627415924341"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}

provider "aws" {
  alias      = "dev"
  region     = "eu-west-3"
  access_key = "153921435903"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://127.0.0.1:4566"
    sts = "http://127.0.0.1:4566"
  }
}
