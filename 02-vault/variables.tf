variable "app_name" {
  description = "Application name used as the Vault mount path prefix"
}

variable "cluster_name" {
  description = "Name of the kind cluster — used to derive the control-plane Docker hostname"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig written by bootstrap.sh (relative to the terraform/ working directory)"
}
