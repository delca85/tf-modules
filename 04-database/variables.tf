variable "app_name" {
  description = "Application name — used as the PostgreSQL cluster name prefix"
}

variable "namespace" {
  description = "Kubernetes namespace where the cluster CRD is created"
}
