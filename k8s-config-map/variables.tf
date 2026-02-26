variable "app_name" {
  description = "Application name — used as config map name prefix"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy into"
}

variable "data" {
  description = "Key-value pairs to populate the config map"
  type        = map(string)
}
