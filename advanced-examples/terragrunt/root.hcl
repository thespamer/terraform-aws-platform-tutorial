locals {
  project_name = "platform-tutorial"
  aws_region   = "us-east-1"
}

remote_state {
  backend = "s3"

  config = {
    bucket       = "CHANGE-ME-terraform-state-123456789"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.generated.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "${local.project_name}"
    }
  }
}
EOF
}
