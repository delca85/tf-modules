# CloudNativePG operator — installed via Helm, manages PostgreSQL clusters as CRDs.
# The operator itself is a Deployment; TF only tracks the Helm release metadata.
resource "helm_release" "cnpg_operator" {
  name             = "cloudnativepg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = "0.21.6"
  namespace        = "cnpg-system"
  create_namespace = true

  wait          = true
  wait_for_jobs = true
  timeout       = 300
}

# PostgreSQL cluster defined as a CloudNativePG CRD.
#
# Key state-vs-reality gap: TF state holds the cluster *spec* (instances, storage,
# bootstrap config). The operator creates the actual Pods, PersistentVolumeClaims,
# Services (e.g. -rw, -ro, -r), and Secrets — none of which appear in TF state.
# A migration tool reading only state will miss all of these derived resources.
resource "kubernetes_manifest" "postgres_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      name      = "${var.app_name}-postgres"
      namespace = var.namespace
    }

    spec = {
      instances = 1

      postgresql = {
        parameters = {
          max_connections = "100"
          shared_buffers  = "128MB"
        }
      }

      bootstrap = {
        initdb = {
          database = var.app_name
          owner    = "appuser"
        }
      }

      storage = {
        size         = "1Gi"
        storageClass = "standard"
      }

      monitoring = {
        enablePodMonitor = false
      }
    }
  }

  computed_fields = [
    "spec.postgresql.parameters",
    "metadata.annotations",
    "metadata.labels",
  ]

  depends_on = [helm_release.cnpg_operator]
}
