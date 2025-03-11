# Configuración básica para preparar el ingress que instalaremos en la Fase 3

resource "kubernetes_config_map" "ingress_nginx_config" {
  metadata {
    name      = "ingress-nginx-config"
    namespace = var.namespace
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "ingress-nginx"
    }
  }
  
  data = {
    "use-forwarded-headers" = "true"
    "compute-full-forwarded-for" = "true"
    "proxy-buffer-size" = "16k"
  }
}

# Network policies para microservicios
resource "kubernetes_network_policy" "default_deny_ingress" {
  metadata {
    name      = "default-deny-ingress"
    namespace = "microservices"
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_ingress_controller" {
  metadata {
    name      = "allow-ingress-controller"
    namespace = "microservices"
  }
  
  spec {
    pod_selector {}
    
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
        pod_selector {
          match_labels = {
            app = "ingress-nginx"
          }
        }
      }
    }
    
    policy_types = ["Ingress"]
  }
}