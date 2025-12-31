locals {
  app_name        = "karpenter-keda-demo"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
}

#Setup VPC
module "vpc" {
  source = "./modules/vpc"

  name = local.app_name
  cidr = local.cidr

  azs             = ["${data.aws_region.current.region}a", "${data.aws_region.current.region}b"]
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}
