output "config_map_name" {
  description = "Kubernetes config map name"
  value       = kubernetes_config_map.app.metadata[0].name
}
