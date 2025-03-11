# En k3s, el storage class local-path ya viene configurado por defecto
# Aquí podemos crear los PVCs persistentes que necesitaremos

resource "kubernetes_persistent_volume_claim" "db_data" {
  metadata {
    name      = "db-data"
    namespace = var.namespace
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "ecommerce-db"
    }
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "prometheus_data" {
  metadata {
    name      = "prometheus-data"
    namespace = "monitoring"
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "prometheus"
    }
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "grafana_data" {
  metadata {
    name      = "grafana-data"
    namespace = "monitoring"
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "grafana"
    }
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}
