variable "app_name" {
  description = "Application name — used as the Redis instance name prefix"
}

variable "namespace" {
  description = "Kubernetes namespace where the Redis CRD is created"
}
