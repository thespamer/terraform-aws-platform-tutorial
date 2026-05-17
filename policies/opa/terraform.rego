package terraform.security

deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket_public_access_block"
  input.resource_changes[_].change.after.block_public_acls == false
  msg := "S3 bucket must block public ACLs"
}

deny[msg] {
  some i
  rc := input.resource_changes[i]
  rc.type == "aws_s3_bucket"
  not rc.change.after.tags.Environment
  msg := sprintf("Resource %s must have Environment tag", [rc.address])
}
