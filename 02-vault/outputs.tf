output "mount_path" {
  description = "Vault KV v2 mount path"
  value       = vault_mount.kv.path
}

output "app_policy_name" {
  description = "Name of the read-only Vault policy for the app"
  value       = vault_policy.app_read.name
}

output "kubernetes_auth_path" {
  description = "Vault Kubernetes auth backend mount path"
  value       = vault_auth_backend.kubernetes.path
}
