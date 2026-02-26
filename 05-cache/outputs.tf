output "redis_service" {
  description = "Redis Service FQDN created by the operator (not tracked in TF state)"
  value       = "${var.app_name}-redis.${var.namespace}.svc.cluster.local"
}
