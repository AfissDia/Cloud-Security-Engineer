# DataHelix - Baseline IAM du compte DEV

resource "aws_iam_role" "security_audit" {

  name = "DataHelix-SecurityAudit"

  description = "Role de consultation securite du compte DEV"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        AWS = "arn:aws:iam::998019410638:root"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = "DataHelix"
    Environment = "DEV"
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_iam_role_policy" "security_audit" {

  name = "DataHelix-NetworkAudit"

  role = aws_iam_role.security_audit.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "AllowNetworkReadOnly"
      Effect = "Allow"

      Action = [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeRouteTables"
      ]

      Resource = "*"
    }]
  })
}
