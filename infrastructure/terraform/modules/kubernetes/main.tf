resource "kubernetes_namespace" "homelab" {
  metadata {
    name = var.namespace
    
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace" "microservices" {
  metadata {
    name = "microservices"
    
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "ecommerce"
    }
  }
}