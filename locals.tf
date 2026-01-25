locals {
  eks_managed_node_groups = {
    main-node-group = {
      name           = "main-node-group"
      max_size       = 3
      desired_size   = 2
      min_size       = 2
      instance_types = ["t3.medium"]

      labels = {
        "karpenter.sh/controller" = "true"
      }

      taints = {
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
}
