variable "name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable endpoint public access"
  type        = bool
  default     = false
}

variable "endpoint_private_access" {
  description = "Enable private access"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet Ids"
  type        = list(string)
}

variable "addons" {
  description = "EKS addons"
  type        = map(any)
  default     = {}
}

variable "eks_managed_node_groups" {
  description = "EKS manged node groups"
  type        = map(any)
  default     = {}
}

variable "partition" {
  description = "AWS partition"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs for the cluster"
  type        = list(string)
  default     = []
}
