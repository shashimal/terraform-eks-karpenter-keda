output "vpc_id" {
  description = "VPC Id"
  value       = module.vpc.default_vpc_id
}

output "private_subnets" {
  description = "Private subnet ids"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet ids"
  value       = module.vpc.public_subnets
}
