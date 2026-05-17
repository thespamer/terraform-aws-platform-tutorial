module "network" {
  source = "../../modules/network"

  name                = local.name_prefix
  cidr_block          = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  tags                = local.common_tags
}

module "artifact_bucket" {
  source = "../../modules/secure-s3-bucket"

  bucket_name = "${local.name_prefix}-artifacts-${data.aws_caller_identity.current.account_id}"
  tags        = local.common_tags
}

module "observability" {
  source = "../../modules/observability"

  name              = local.name_prefix
  retention_in_days = 14
  tags              = local.common_tags
}

data "aws_caller_identity" "current" {}
