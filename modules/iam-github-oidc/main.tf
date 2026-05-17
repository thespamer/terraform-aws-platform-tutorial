resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Thumbprint atual usado amplamente para GitHub OIDC.
  # Em ambientes críticos, valide periodicamente.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org_or_user}/${var.github_repo}:ref:refs/heads/${var.allowed_branch}",
        "repo:${var.github_org_or_user}/${var.github_repo}:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-terraform-${var.github_repo}"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

data "aws_iam_policy_document" "terraform_backend_access" {
  statement {
    sid    = "AllowTerraformStateBucketList"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.state_bucket_arn
    ]
  }

  statement {
    sid    = "AllowTerraformStateObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${var.state_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowKmsForState"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      var.kms_key_arn
    ]
  }

  # Tutorial simplificado: em produção, reduza permissões por stack.
  statement {
    sid    = "AllowTerraformManageDemoResources"
    effect = "Allow"

    actions = [
      "ec2:*",
      "s3:*",
      "cloudwatch:*",
      "logs:*",
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_backend_access" {
  name   = "terraform-backend-access-${var.github_repo}"
  policy = data.aws_iam_policy_document.terraform_backend_access.json
}

resource "aws_iam_role_policy_attachment" "terraform_backend_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_backend_access.arn
}
