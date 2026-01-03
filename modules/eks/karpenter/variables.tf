variable "cluster_name" {
  description = "EKS cluster name"
  type = string
}

variable "create_pod_identity_association" {
  description = "Enable pod identity for Karpenter"
  type = bool
  default = true
}
variable "create_node_iam_role" {
  description = "Create default node IAM role"
  type = bool
  default = false
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. Note: If `ipv6` is specified, the `AmazonEKS_CNI_IPv6_Policy` must exist in the account. This policy is created by the EKS module with `create_cni_ipv6_iam_policy = true`"
  type        = string
  default     = "ipv4"
}

variable "worker_iam_role_arn" {
  description = "Worker IAM role arn"
  type = string
  default = null
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