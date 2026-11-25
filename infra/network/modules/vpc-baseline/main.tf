terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

# 1. Réseau virtuel
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "DataHelix-${var.environment}-VPC"
    Environment = var.environment
    Project     = "DataHelix"
    ManagedBy   = "OpenTofu"
  }
}

# 2. Sous-réseau privé
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "DataHelix-${var.environment}-Private"
    Environment = var.environment
  }
}

# 3. Groupe de sécurité restrictif
resource "aws_security_group" "baseline" {
  name        = "DataHelix-${var.environment}-SG"
  description = "Security Group restrictif DataHelix"
  vpc_id      = aws_vpc.main.id

  # Aucun flux entrant autorisé
  ingress = []

  # Aucun flux sortant autorisé
  egress = []

  tags = {
    Name        = "DataHelix-${var.environment}-SG"
    Environment = var.environment
  }
}


# Security Group par défaut du VPC
# Politique Deny by Default

resource "aws_default_security_group" "restricted" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name        = "DataHelix-${var.environment}-Default-SG"
    Environment = var.environment
    Project     = "DataHelix"
    ManagedBy   = "OpenTofu"
  }
}
