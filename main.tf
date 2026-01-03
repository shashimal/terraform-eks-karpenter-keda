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
module "eks" {
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

module "karpenter" {
  source = "./modules/eks/karpenter"

  cluster_name = module.eks.cluster_name
  create_pod_identity_association = true
  create_access_entry = true
  create_node_iam_role = false
  worker_iam_role_arn = module.eks_workers_iam_role.arn

  depends_on = [module.eks]
}
