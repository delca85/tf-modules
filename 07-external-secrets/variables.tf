variable "app_name" {
  description = "Application name — used as the ExternalSecret name prefix"
}

variable "namespace" {
  description = "Kubernetes namespace where ESO CRDs are created"
}

variable "vault_address" {
  description = "URL of the Vault server reachable from within the cluster"
}

variable "vault_mount" {
  description = "Vault KV v2 mount path to pull secrets from"
}

variable "vault_token" {
  description = "Vault token used by the SecretStore to authenticate"
  sensitive   = true
}
