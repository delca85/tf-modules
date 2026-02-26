output "db_secret_name" {
  description = "Name of the K8s Secret created by ESO for DB credentials (not tracked in TF state)"
  value       = "${var.app_name}-db-credentials"
}

output "redis_secret_name" {
  description = "Name of the K8s Secret created by ESO for Redis credentials (not tracked in TF state)"
  value       = "${var.app_name}-redis-credentials"
}
