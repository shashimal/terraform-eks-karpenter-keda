variable "keda_version" {
  description = "Version of KEDA to install"
  type        = string
  default     = "2.18.0"
}

variable "keda_namespace" {
  description = "KEDA namespace"
  type = string
  default = "keda-system"
}

variable "enable_prometheus_metrics" {
  description = "Enable Prometheus metrics for KEDA components"
  type        = bool
  default     = true
}

variable "log_level" {
  description = "Log level for KEDA components"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, error."
  }
}


variable "cluster_name" {
  description = "EKS cluster name for Pod Identity associations"
  type        = string
}

variable "enable_pod_identity" {
  description = "Enable EKS Pod Identity for KEDA to access AWS services"
  type        = bool
  default     = true
}



variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
