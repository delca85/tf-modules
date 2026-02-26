output "cluster_name" {
  description = "CloudNativePG cluster name"
  value       = "${var.app_name}-postgres"
}

output "rw_service" {
  description = "Read-write Service FQDN created by the operator (not tracked in TF state)"
  value       = "${var.app_name}-postgres-rw.${var.namespace}.svc.cluster.local"
}
