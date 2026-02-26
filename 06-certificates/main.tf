# cert-manager — installs the Certificate controller and CRDs.
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.16.2"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }

  wait    = true
  timeout = 300
}

# Self-signed ClusterIssuer — cluster-wide, so no namespace needed.
resource "kubernetes_manifest" "self_signed_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "self-signed"
    }

    spec = {
      selfSigned = {}
    }
  }

  depends_on = [helm_release.cert_manager]
}

# TLS Certificate for the app.
#
# Key state-vs-reality gap: TF state holds the Certificate *spec* (DNS names,
# duration, issuer ref). cert-manager creates an actual Kubernetes Secret
# (named "${var.app_name}-tls-secret") containing the signed certificate and
# private key. That Secret is entirely outside TF state.
# A migration tool will see the Certificate CRD but miss the TLS Secret it produces.
resource "kubernetes_manifest" "app_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "${var.app_name}-tls"
      namespace = var.namespace
    }

    spec = {
      secretName  = "${var.app_name}-tls-secret"
      duration    = "2160h"
      renewBefore = "360h"

      issuerRef = {
        name  = "self-signed"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }

      dnsNames = [
        "${var.app_name}.local",
        "*.${var.app_name}.local",
      ]

      privateKey = {
        algorithm = "RSA"
        size      = 2048
      }
    }
  }

  depends_on = [kubernetes_manifest.self_signed_issuer]
}
