data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
################################ EKS ################################
#####################################################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}