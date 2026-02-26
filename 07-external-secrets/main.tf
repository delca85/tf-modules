# External Secrets Operator — watches ExternalSecret CRDs and syncs secrets
# from external backends (Vault in this case) into Kubernetes Secrets.
resource "helm_release" "external_secrets_operator" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.10.7"
  namespace        = "external-secrets"
  create_namespace = true

  wait    = true
  timeout = 300
}

# Vault token stored as a K8s Secret so the SecretStore can authenticate.
# Note: in production this would use Vault's Kubernetes auth backend instead.
resource "kubernetes_secret" "vault_token" {
  metadata {
    name      = "vault-token"
    namespace = var.namespace
  }

  data = {
    token = var.vault_token
  }

  type = "Opaque"
}

# SecretStore — points ESO at the local Vault instance.
# TF state holds the *configuration* of where secrets come from.
# The actual secret values are never written to TF state.
resource "kubernetes_manifest" "vault_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"

    metadata = {
      name      = "vault-backend"
      namespace = var.namespace
    }

    spec = {
      provider = {
        vault = {
          server  = var.vault_address
          path    = var.vault_mount
          version = "v2"

          auth = {
            tokenSecretRef = {
              name = kubernetes_secret.vault_token.metadata[0].name
              key  = "token"
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets_operator, kubernetes_secret.vault_token]
}

# ExternalSecret for database credentials.
#
# Key state-vs-reality gap: TF state holds the ExternalSecret *spec*
# (which Vault paths to pull, which K8s Secret to create, refresh interval).
# ESO creates the actual K8s Secret "${var.app_name}-db-credentials" containing
# the real credential values — this Secret is completely outside TF state.
# A migration tool reading state sees the intent but not the materialised secret.
resource "kubernetes_manifest" "db_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "${var.app_name}-db-credentials"
      namespace = var.namespace
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = "vault-backend"
        kind = "SecretStore"
      }

      target = {
        name           = "${var.app_name}-db-credentials"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = "database/credentials"
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key      = "database/credentials"
            property = "password"
          }
        },
        {
          secretKey = "host"
          remoteRef = {
            key      = "database/credentials"
            property = "host"
          }
        },
      ]
    }
  }

  depends_on = [kubernetes_manifest.vault_secret_store]
}

# ExternalSecret for Redis connection info
resource "kubernetes_manifest" "redis_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "${var.app_name}-redis-credentials"
      namespace = var.namespace
    }

    spec = {
      refreshInterval = "1h"

      secretStoreRef = {
        name = "vault-backend"
        kind = "SecretStore"
      }

      target = {
        name           = "${var.app_name}-redis-credentials"
        creationPolicy = "Owner"
      }

      data = [
        {
          secretKey = "host"
          remoteRef = {
            key      = "cache/credentials"
            property = "host"
          }
        },
        {
          secretKey = "port"
          remoteRef = {
            key      = "cache/credentials"
            property = "port"
          }
        },
      ]
    }
  }

  depends_on = [kubernetes_manifest.vault_secret_store]
}
