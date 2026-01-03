module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = var.cluster_name

  create_pod_identity_association = var.create_pod_identity_association

  create_access_entry = var.create_access_entry
  access_entry_type = var.access_entry_type

  create_node_iam_role = var.create_node_iam_role
  node_iam_role_arn     = var.worker_iam_role_arn

  cluster_ip_family = var.cluster_ip_family
}
