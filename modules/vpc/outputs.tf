output "vpc_id" {
  description = "VPC Id"
  value       = module.vpc.vpc_id
}

output "default_security_group_id" {
  description = "Default security group ID"
  value       = module.vpc.default_security_group_id
}

output "private_subnets" {
  description = "Private subnet ids"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet ids"
  value       = module.vpc.public_subnets
}
