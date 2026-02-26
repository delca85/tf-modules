resource "kubernetes_config_map" "app" {
  metadata {
    name      = "${var.prefix}-config"
    namespace = var.namespace
  }

  data = var.data
}
