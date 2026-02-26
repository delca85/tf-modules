resource "kubernetes_secret" "app" {
  metadata {
    name      = "${var.prefix}-secret"
    namespace = var.namespace
  }

  data = var.data
}
