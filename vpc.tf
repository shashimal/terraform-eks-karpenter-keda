#Setup VPC
module "vpc" {
  source = "./modules/vpc"

  name = local.app_name
  cidr = local.cidr

  azs             = ["${data.aws_region.current.region}a", "${data.aws_region.current.region}b"]
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  private_subnet_tags = {
    Name                              = "App-Subnet"
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = local.app_name
  }

}