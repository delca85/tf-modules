output "certificate_secret_name" {
  description = "Name of the TLS Secret created by cert-manager (not tracked in TF state)"
  value       = "${var.app_name}-tls-secret"
}
