resource "aws_iam_openid_connect_provider" "this" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:awscommunitymx/*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "github_oidc_role"
  assume_role_policy = data.aws_iam_policy_document.oidc.json
}

data "aws_iam_policy_document" "cdk" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cdk-*",
    ]
  }
}

resource "aws_iam_policy" "cdk" {
  name        = "cdk-policy"
  description = "Policy used for CDK deployments"
  policy      = data.aws_iam_policy_document.cdk.json
}

resource "aws_iam_role_policy_attachment" "attach-cdk" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cdk.arn
}
resource "aws_iam_role_policy_attachment" "appsync_admin_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppSyncAdministrator"
}

resource "aws_iam_role_policy_attachment" "cloudformation_full_access_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "Lambda_Full_Access_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_policy" "dynamodb_full_access" {
  name        = "dynamodb-full-access-policy"
  description = "Policy for full access to DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.dynamodb_full_access.arn
}

resource "aws_iam_policy" "cognito_access" {
  name        = "cognito-access-policy"
  description = "Policy for Cognito User Pool access (non-production)"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCognitoUserPoolAccess"
        Effect   = "Allow"
        Action   = ["cognito-idp:*"]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:ResourceTag/Environment": "production"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_access_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cognito_access.arn
}

resource "aws_iam_policy" "step_functions_access" {
  name        = "step-functions-access-policy"
  description = "Policy for AWS Step Functions full access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "states:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_access_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.step_functions_access.arn
}
