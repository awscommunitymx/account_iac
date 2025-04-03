

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
      "s3:GetObject" 
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
  role       =  aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "Lambda_Full_Access_attachment" {
  role       =  aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_attachment" {
  role       =  aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
