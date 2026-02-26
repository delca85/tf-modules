output "app_namespace" {
  description = "Kubernetes namespace where workloads are deployed"
  value       = kubernetes_namespace.app.metadata[0].name
}
