output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID da VPC."
}

output "public_subnet_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "IDs das subnets públicas."
}
