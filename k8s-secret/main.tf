resource "kubernetes_secret" "app" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = var.namespace
  }

  data = {
    db_password = "changeme"
    api_key     = "local-dev-key"
  }
}
