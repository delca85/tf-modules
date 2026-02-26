resource "kubernetes_namespace" "app" {
  metadata {
    name   = var.name
    labels = var.labels
  }
}
