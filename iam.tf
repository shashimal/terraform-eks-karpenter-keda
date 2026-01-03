locals {
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

}

module "eks_workers_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name        = "${local.app_name}-workers"
  description = "IAM Role for the workers in EKS Cluster named ${local.app_name}"

  trust_policy_permissions = {
    ec2 = {
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]
      principals = [
        {
          type = "Service"
          identifiers = ["ec2.amazonaws.com"]
        }
      ]
    }
  }

  policies = {
    AmazonEKSWorkerNodePolicy = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly= "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
    AmazonSSMManagedInstanceCore = "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore",
    AmazonEKS_CNI_Policy= "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy",
  }
}
