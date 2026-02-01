output "keda_namespace" {
  description = "Namespace where KEDA is installed"
  value       = helm_release.keda.namespace
}

output "keda_release_name" {
  description = "Helm release name for KEDA"
  value       = helm_release.keda.name
}

output "keda_version" {
  description = "Version of KEDA installed"
  value       = helm_release.keda.version
}

output "keda_status" {
  description = "Status of KEDA Helm release"
  value       = helm_release.keda.status
}

output "keda_operator_service_account" {
  description = "Service account name for KEDA operator"
  value       = "keda-operator"
}

output "keda_metrics_server_service_account" {
  description = "Service account name for KEDA metrics server"
  value       = "keda-metrics-server"
}
