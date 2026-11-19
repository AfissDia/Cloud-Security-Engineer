#n Politique SCP - Protection de CloudTrail
# Projet DataHelix

resource "aws_organizations_policy" "protect_security" {

  name        = "DataHelix-Protect-Security"
  description = "Protection des journaux CloudTrail et de l'organisation"

  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyCloudTrailTampering"
        Effect = "Deny"

        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors"
        ]

        Resource = "*"
      },

      {
        Sid    = "DenyLeaveOrganization"
        Effect = "Deny"

        Action = [
          "organizations:LeaveOrganization"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Project   = "DataHelix"
    ManagedBy = "OpenTofu"
  }
}

# Application de la SCP à Workloads

resource "aws_organizations_policy_attachment" "workloads" {

  policy_id = aws_organizations_policy.protect_security.id

  target_id = aws_organizations_organizational_unit.workloads.id
}

# Application de la SCP à Security

resource "aws_organizations_policy_attachment" "security" {

  policy_id = aws_organizations_policy.protect_security.id

  target_id = aws_organizations_organizational_unit.security.id
}
