variable "app_name" {
  description = "Application name used as resource prefix"
}

variable "environment" {
  description = "Environment label"
}

variable "aws_region" {
  description = "AWS region for AZ naming"
  default     = "us-east-1"
}
