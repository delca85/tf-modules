data "local_sensitive_file" "kubeconfig" {
  filename = var.kubeconfig_path
}

locals {
  kubeconfig  = yamldecode(data.local_sensitive_file.kubeconfig.content)
  k8s_ca_cert = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
}

# KV v2 secrets engine — where app secrets live
resource "vault_mount" "kv" {
  path        = "${var.app_name}/kv"
  type        = "kv-v2"
  description = "KV v2 secrets engine for ${var.app_name}"
}

# Static database credentials stored in Vault (not in TF state — only metadata is)
resource "vault_kv_secret_v2" "db_credentials" {
  mount               = vault_mount.kv.path
  name                = "database/credentials"
  delete_all_versions = true

  data_json = jsonencode({
    username = "appuser"
    password = "changeme-local"
    host     = "testapp-postgres-rw.testapp.svc.cluster.local"
    port     = "5432"
    dbname   = var.app_name
  })
}

# Static Redis connection info
resource "vault_kv_secret_v2" "redis_credentials" {
  mount               = vault_mount.kv.path
  name                = "cache/credentials"
  delete_all_versions = true

  data_json = jsonencode({
    host = "testapp-redis.testapp.svc.cluster.local"
    port = "6379"
  })
}

# Policy granting read-only access to all secrets under this app's mount
resource "vault_policy" "app_read" {
  name = "${var.app_name}-read"

  policy = <<-EOT
    path "${var.app_name}/kv/data/*" {
      capabilities = ["read", "list"]
    }
    path "${var.app_name}/kv/metadata/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

# Kubernetes auth backend — allows pods with the right SA to authenticate to Vault
resource "vault_auth_backend" "kubernetes" {
  type        = "kubernetes"
  path        = "kubernetes"
  description = "Kubernetes auth backend for ${var.app_name}"
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://${var.cluster_name}-control-plane:6443"
  kubernetes_ca_cert = local.k8s_ca_cert
}

resource "vault_kubernetes_auth_backend_role" "app" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "${var.app_name}-app"
  bound_service_account_names      = ["${var.app_name}-app"]
  bound_service_account_namespaces = [var.app_name]
  token_policies                   = [vault_policy.app_read.name]
  token_ttl                        = 3600
}
