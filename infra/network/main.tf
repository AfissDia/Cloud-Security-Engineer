# PROD
module "prod" {
  source = "./modules/vpc-baseline"

  providers = {
    aws = aws.prod
  }

  environment = "PROD"
  vpc_cidr    = "10.10.0.0/16"
  subnet_cidr = "10.10.1.0/24"
}

# STAGING
module "staging" {
  source = "./modules/vpc-baseline"

  providers = {
    aws = aws.staging
  }

  environment = "STAGING"
  vpc_cidr    = "10.20.0.0/16"
  subnet_cidr = "10.20.1.0/24"
}

# DEV
module "dev" {
  source = "./modules/vpc-baseline"

  providers = {
    aws = aws.dev
  }

  environment = "DEV"
  vpc_cidr    = "10.30.0.0/16"
  subnet_cidr = "10.30.1.0/24"
}
