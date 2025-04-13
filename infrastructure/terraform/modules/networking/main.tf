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
            "app.kubernetes.io/component" = "controller"
            "app.kubernetes.io/instance"  = "ingress-nginx"
            "app.kubernetes.io/name"      = "ingress-nginx"
          }
        }
      }
    }
    
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_intra_namespace" {
  metadata {
    name      = "allow-intra-namespace"
    namespace = "microservices"
  }

  spec {
    pod_selector {}

    ingress {
      from {
        pod_selector {}  # Selector vacío = selecciona todos los pods en el mismo namespace
      }
    }

    policy_types = ["Ingress"]
  }
}