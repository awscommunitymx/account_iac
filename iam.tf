

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

