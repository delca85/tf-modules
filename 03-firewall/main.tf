# Application namespace — all workloads live here
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "local"
    }
  }
}

# Default deny-all ingress — anything not explicitly allowed is blocked.
# This simulates the baseline policy you'd push to a firewall appliance.
resource "kubernetes_network_policy" "default_deny_ingress" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# Allow intra-namespace traffic (pods within the same namespace can talk freely)
resource "kubernetes_network_policy" "allow_intra_namespace" {
  metadata {
    name      = "allow-intra-namespace"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.app_name
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

# Allow app pods to reach the Postgres cluster on port 5432.
# TF writes this NetworkPolicy CRD — the CNI plugin (kindnet/Calico) enforces
# it as actual iptables rules. The enforced state is invisible to TF state.
resource "kubernetes_network_policy" "allow_app_to_db" {
  metadata {
    name      = "allow-app-to-db"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "cnpg.io/cluster" = "${var.app_name}-postgres"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = var.app_name
          }
        }
      }

      ports {
        port     = "5432"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

# Allow app pods to reach Redis on port 6379
resource "kubernetes_network_policy" "allow_app_to_redis" {
  metadata {
    name      = "allow-app-to-redis"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app" = "${var.app_name}-redis"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = var.app_name
          }
        }
      }

      ports {
        port     = "6379"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
