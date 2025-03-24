locals {
  persistent_volume_claims = {
    "db-data" = {
      namespace = var.namespaces["databases"]
      app       = "ecommerce-db"
      storage   = "5Gi"
    },
    "prometheus-data" = {
      namespace = var.namespaces["monitoring"]
      app       = "prometheus"
      storage   = "8Gi"
    },
    "grafana-data" = {
      namespace = var.namespaces["monitoring"]
      app       = "grafana"
      storage   = "2Gi"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  for_each = local.persistent_volume_claims

  metadata {
    name      = each.key
    namespace = each.value.namespace
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = each.value.app
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class

    resources {
      requests = {
        storage = each.value.storage
      }
    }
  }
  wait_until_bound = false
}
