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

#Setup EKS Cluster
module "eks_cluster" {
  source             = "./modules/eks/cluster"
  name               = local.app_name
  kubernetes_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  endpoint_private_access = true
  endpoint_public_access = true

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = local.eks_managed_node_groups

}
