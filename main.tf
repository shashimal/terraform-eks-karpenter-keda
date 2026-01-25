locals {
  app_name        = "karpenter-keda-demo"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  karpenter_nodeclasses = [
    {
      nodeclass_name = "default"
      karpenter_subnet_selector_maps = [
        {
          tags = {
            "karpenter.sh/discovery" = local.app_name
          }
        }
      ]
      karpenter_node_role = module.eks_workers_iam_role.arn
      karpenter_security_group_selector_maps = [
        {
          tags = {
            "karpenter.sh/discovery" = local.app_name
          }
        },
        # {
        #   id = module.ingress_traffic_sg.security_group_id
        #
        # }
        # {
        #   id = module.rds_security_group.security_group_id
        # }

      ]
      karpenter_ami_selector_maps = [
        {
          "alias" = "bottlerocket@latest"
        }
      ]
      karpenter_node_user_data = ""
      karpenter_node_tags_map = {
        "karpenter.sh/discovery" = module.eks.cluster_name,
        "eks:cluster-name"       = module.eks.cluster_name,
      }
      karpenter_block_device_mapping = [
        {
          #karpenter_root_volume_size
          "deviceName" = "/dev/xvda"
          "ebs" = {
            "encrypted"           = true
            "volumeSize"          = "5Gi"
            "volumeType"          = "gp3"
            "deleteOnTermination" = true
          }
          }, {
          #karpenter_ephemeral_volume_size
          "deviceName" = "/dev/xvdb",
          "ebs" = {
            "encrypted"           = true
            "volumeSize"          = "50Gi"
            "volumeType"          = "gp3"
            "deleteOnTermination" = true
          }
        }
      ]
      karpenter_node_metadata_options = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 1
        httpTokens              = "required"
      }
      karpenter_node_kubelet = {
        clusterDNS = []
      }
    }
  ]

  karpenter_nodepools = [
    {
      nodepool_name                     = "default"
      nodeclass_name                    = "default"
      karpenter_nodepool_node_labels    = {}
      karpenter_nodepool_annotations    = {}
      karpenter_nodepool_node_taints    = []
      karpenter_nodepool_startup_taints = []
      karpenter_requirements = [
        {
          key      = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values   = ["t"]
          }, {
          key      = "karpenter.k8s.aws/instance-cpu"
          operator = "In"
          values   = ["2"]
          }, {
          key      = "karpenter.k8s.aws/instance-memory"
          operator = "In"
          values   = ["8192"]
          }, {
          key      = "karpenter.k8s.aws/instance-generation"
          operator = "Gt"
          values   = ["2"]
          }, {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
          }, {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
          }, {
          key      = "kubernetes.io/os"
          operator = "In"
          values   = ["linux"]
        }
      ]
      karpenter_nodepool_disruption = {
        consolidation_policy     = "WhenEmptyOrUnderutilized" # WhenEmpty or WhenEmptyOrUnderutilized
        consolidate_after        = "20s"
        expire_after             = "168h" # 7d | 168h | 1w
        termination_grace_period = "5m"
      }
      karpenter_nodepool_disruption_budgets = [{
        nodes = "10%"
      }]
      karpenter_nodepool_weight = 10
    }
  ]
}

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

#Setup EKS Cluster
module "eks" {
  source             = "./modules/eks/cluster"
  name               = local.app_name
  kubernetes_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  endpoint_private_access                  = true
  endpoint_public_access                   = true

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
  node_security_group_tags = {
    "karpenter.sh/discovery" = local.app_name
  }

}

module "karpenter" {
  source = "./modules/eks/karpenter"

  cluster_name                    = module.eks.cluster_name
  create_pod_identity_association = true
  create_access_entry             = true
  create_node_iam_role            = false
  worker_iam_role_arn             = module.eks_workers_iam_role.arn
  cluster_endpoint                = module.eks.cluster_endpoint
  karpenter_nodeclasses           = local.karpenter_nodeclasses
  karpenter_nodepools             = local.karpenter_nodepools

  depends_on = [module.eks]
}
