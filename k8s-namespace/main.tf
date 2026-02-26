resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }
}
