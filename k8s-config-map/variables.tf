variable "prefix" {
  description = "Config map name prefix"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy into"
}

variable "data" {
  description = "Key-value pairs to populate the config map"
  type        = map(string)
}
