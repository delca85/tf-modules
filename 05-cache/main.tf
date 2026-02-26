# Redis Operator (OT Container Kit) — installs the CRD controllers.
resource "helm_release" "redis_operator" {
  name             = "redis-operator"
  repository       = "https://ot-container-kit.github.io/helm-charts"
  chart            = "redis-operator"
  version          = "0.23.0"
  namespace        = "redis-operator"
  create_namespace = true

  wait    = true
  timeout = 300
}

# Redis standalone instance defined as a CRD.
#
# Key state-vs-reality gap: TF state holds the Redis spec (image, resources,
# storage config). The operator reconciles this into a StatefulSet, Service,
# and PersistentVolumeClaim — none of which appear in TF state.
# The actual connection string is also derived at runtime by the operator.
resource "kubernetes_manifest" "redis_standalone" {
  manifest = {
    apiVersion = "redis.redis.opstreelabs.in/v1beta2"
    kind       = "Redis"

    metadata = {
      name      = "${var.app_name}-redis"
      namespace = var.namespace
      labels = {
        "app" = "${var.app_name}-redis"
      }
    }

    spec = {
      kubernetesConfig = {
        image           = "quay.io/opstree/redis:v7.0.15"
        imagePullPolicy = "IfNotPresent"
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      storage = {
        volumeClaimTemplate = {
          spec = {
            accessModes = ["ReadWriteOnce"]
            resources = {
              requests = {
                storage = "1Gi"
              }
            }
          }
        }
      }

      redisConfig = {
        additionalRedisConfig = "maxmemory 128mb\nmaxmemory-policy allkeys-lru\n"
      }
    }
  }

  depends_on = [helm_release.redis_operator]
}
