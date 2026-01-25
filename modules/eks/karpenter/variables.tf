variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  type        = string
}

variable "create_pod_identity_association" {
  description = "Enable pod identity for Karpenter"
  type        = bool
  default     = true
}
variable "create_node_iam_role" {
  description = "Create default node IAM role"
  type        = bool
  default     = false
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. Note: If `ipv6` is specified, the `AmazonEKS_CNI_IPv6_Policy` must exist in the account. This policy is created by the EKS module with `create_cni_ipv6_iam_policy = true`"
  type        = string
  default     = "ipv4"
}

variable "worker_iam_role_arn" {
  description = "Worker IAM role arn"
  type        = string
  default     = null
}

variable "create_access_entry" {
  description = "Determines whether an access entry is created for the IAM role used by the node IAM role, `enable` it when using self managed nodes"
  type        = bool
  default     = true
}

variable "access_entry_type" {
  description = "Type of the access entry. `EC2_LINUX`, `FARGATE_LINUX`, or `EC2_WINDOWS`; defaults to `EC2_LINUX`"
  type        = string
  default     = "EC2_LINUX"
}

##################
# Karpenter CRDs #
##################
variable "karpenter_crd_namespace" {
  description = "Namespace to deploy karpenter"
  type        = string
  default     = "kube-system"
}

variable "karpenter_crd_release_name" {
  description = "Release name for Karpenter"
  type        = string
  default     = "karpenter-crd"
}

variable "karpenter_crd_chart_name" {
  description = "Chart name for Karpenter"
  type        = string
  default     = "karpenter-crd"
}

variable "karpenter_crd_chart_repository" {
  description = "Chart repository for Karpenter"
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "karpenter_crd_chart_version" {
  description = "Chart version for Karpenter"
  type        = string
  default     = "1.8.1"
}

###############
## Karpenter ##
###############
variable "karpenter_namespace" {
  description = "Namespace to deploy karpenter"
  type        = string
  default     = "kube-system"
}

variable "karpenter_release_name" {
  description = "Release name for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "karpenter_chart_name" {
  description = "Chart name for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "karpenter_chart_repository" {
  description = "Chart repository for Karpenter"
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "karpenter_chart_version" {
  description = "Chart version for Karpenter"
  type        = string
  default     = "1.8.1"
}

variable "karpenter_nodepools" {
  description = "List of Provisioner maps"
  type = list(object({
    nodepool_name                     = string
    nodeclass_name                    = string
    karpenter_nodepool_node_labels    = map(string)
    karpenter_nodepool_annotations    = map(string)
    karpenter_nodepool_node_taints    = list(map(string))
    karpenter_nodepool_startup_taints = list(map(string))
    karpenter_requirements = list(object({
      key      = string
      operator = string
      values   = list(string)
      })
    )
    karpenter_nodepool_disruption = object({
      consolidation_policy     = string
      consolidate_after        = string
      expire_after             = string
      termination_grace_period = string
    })
    karpenter_nodepool_disruption_budgets = list(map(any))
    karpenter_nodepool_weight             = number
  }))
  default = [{
    nodepool_name                     = "default"
    nodeclass_name                    = "default"
    karpenter_nodepool_node_labels    = {}
    karpenter_nodepool_annotations    = {}
    karpenter_nodepool_node_taints    = []
    karpenter_nodepool_startup_taints = []
    karpenter_requirements = [{
      key      = "karpenter.k8s.aws/instance-category"
      operator = "In"
      values   = ["m"]
      }, {
      key      = "karpenter.k8s.aws/instance-cpu"
      operator = "In"
      values   = ["4,8,16"]
      }, {
      key      = "karpenter.k8s.aws/instance-generation"
      operator = "Gt"
      values   = ["5"]
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
      consolidate_after        = "5m"
      expire_after             = "168h" # 7d | 168h | 1w
      termination_grace_period = "5h"
    }
    karpenter_nodepool_disruption_budgets = [{
      nodes = "10%"
    }]
    karpenter_nodepool_weight = 10
  }]
}

variable "karpenter_nodeclasses" {
  description = "List of nodetemplate maps"
  type = list(object({
    nodeclass_name                         = string
    karpenter_subnet_selector_maps         = list(map(any))
    karpenter_security_group_selector_maps = list(map(any))
    karpenter_ami_selector_maps            = list(map(any))
    karpenter_node_role                    = string
    karpenter_node_tags_map                = map(string)
    karpenter_node_user_data               = string
    karpenter_node_metadata_options        = map(any)
    karpenter_node_kubelet                 = map(any)
    karpenter_block_device_mapping = list(object({
      deviceName = string
      ebs = object({
        encrypted           = bool
        volumeSize          = string
        volumeType          = string
        kmsKeyID            = optional(string)
        deleteOnTermination = bool
      })
    }))
  }))
  default = [{
    nodeclass_name                         = "default"
    karpenter_block_device_mapping         = []
    karpenter_ami_selector_maps            = []
    karpenter_node_user_data               = ""
    karpenter_node_role                    = "module.eks.worker_iam_role_name"
    karpenter_subnet_selector_maps         = []
    karpenter_security_group_selector_maps = []
    karpenter_node_tags_map                = {}
    karpenter_node_kubelet                 = {}
    karpenter_node_metadata_options = {
      httpEndpoint            = "enabled"
      httpProtocolIPv6        = "disabled"
      httpPutResponseHopLimit = 1
      httpTokens              = "required"
    }
  }]
}

variable "karpenter_pod_resources" {
  description = "Karpenter Pod Resource"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "1"
      memory = "2Gi"
    }
    limits = {
      cpu    = "1"
      memory = "2Gi"
    }
  }
}

variable "enable_service_monitoring" {
  description = "Allow scraping of Karpenter metrics"
  type        = bool
  default     = false
}


################################################################################
# IAM Role for Service Account (IRSA)
################################################################################
variable "enable_irsa" {
  description = "Determines whether to enable support for IAM role for service accounts"
  type        = bool
  default     = true
}

variable "enable_inline_policy" {
  description = "Determines whether the controller policy is created as a standard IAM policy or inline IAM policy. This can be enabled when the error `LimitExceeded: Cannot exceed quota for PolicySize: 6144` is received since standard IAM policies have a limit of 6,144 characters versus an inline role policy's limit of 10,240 ([Reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html))"
  type        = bool
  default     = false
}

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Determines whether an IAM role is created"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = "ap-southeast-1"
}
