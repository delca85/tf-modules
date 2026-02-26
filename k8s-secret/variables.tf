variable "prefix" {
  description = "Secret name prefix"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy into"
}

variable "data" {
  description = "The secret data"
  type        = map(string)
}
