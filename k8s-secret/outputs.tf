output "secret_name" {
  description = "Kubernetes secret name"
  value       = kubernetes_secret.app.metadata[0].name
}
