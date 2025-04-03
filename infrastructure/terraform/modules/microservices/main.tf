terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1"
  namespace  = var.network_namespace

  set {
    name  = "controller.kind"
    value = "Deployment"
  }

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.metrics.enabled"
    value = var.enable_metrics
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "false"
  }

  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels"
    value = "{}"
  }

  # Aquí referenciamos el ConfigMap existente en lugar de duplicar configuración
  set {
    name  = "controller.configMapNamespace"
    value = var.network_namespace
  }

  set {
    name  = "controller.configMapName"
    value = var.ingress_config_map_name
  }

  # Solo agregamos configuraciones que no están en el ConfigMap existente
  values = [
    file("${path.module}/templates/ingress-additional-values.yaml")
  ]
}

# 2. Despliegue de cert-manager para SSL
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.1"
  namespace  = var.network_namespace

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [helm_release.ingress_nginx]
}

# 3. Desplegar configuración de ClusterIssuer para cert-manager
resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
YAML

  depends_on        = [helm_release.cert_manager]
  server_side_apply = true
  wait              = true
  wait_for_rollout  = true
}

# 4. Despliegue de la API de productos (backend)
resource "kubernetes_deployment" "products_api" {
  metadata {
    name      = "products-api"
    namespace = var.namespace
    labels = {
      app     = "products-api"
      part-of = "ecommerce"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "products-api"
      }
    }

    template {
      metadata {
        labels = {
          app     = "products-api"
          part-of = "ecommerce"
        }
        annotations = var.enable_metrics ? {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8080"
          "prometheus.io/path"   = "/metrics"
        } : {}
      }

      spec {
        container {
          name  = "api"
          image = "nginx:alpine" # Reemplaza con tu imagen real

          port {
            container_port = 80
          }

          env {
            name  = "DB_HOST"
            value = "postgres"
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "username"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "password"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "database"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

}

resource "kubernetes_service" "products_api" {
  metadata {
    name      = "products-api"
    namespace = var.namespace
    labels = {
      app     = "products-api"
      part-of = "ecommerce"
    }
  }

  spec {
    selector = {
      app = "products-api"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# 5. Despliegue de la API de órdenes
resource "kubernetes_deployment" "orders_api" {
  metadata {
    name      = "orders-api"
    namespace = var.namespace
    labels = {
      app     = "orders-api"
      part-of = "ecommerce"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "orders-api"
      }
    }

    template {
      metadata {
        labels = {
          app     = "orders-api"
          part-of = "ecommerce"
        }
        annotations = var.enable_metrics ? {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8080"
          "prometheus.io/path"   = "/metrics"
        } : {}
      }

      spec {
        container {
          name  = "api"
          image = "nginx:alpine" # Reemplaza con tu imagen real

          port {
            container_port = 80
          }

          env {
            name  = "DB_HOST"
            value = "postgres"
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "username"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "password"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "database"
              }
            }
          }

          env {
            name  = "PRODUCTS_API_URL"
            value = "http://products-api"
          }

          liveness_probe {
            http_get {
              path = "/" #Modify for ports of actual microservices...same below
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.products_api]
}

resource "kubernetes_service" "orders_api" {
  metadata {
    name      = "orders-api"
    namespace = var.namespace
    labels = {
      app     = "orders-api"
      part-of = "ecommerce"
    }
  }

  spec {
    selector = {
      app = "orders-api"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# 6. Despliegue de la aplicación web (frontend)
resource "kubernetes_deployment" "ecommerce_web" {
  metadata {
    name      = "ecommerce-web"
    namespace = var.namespace
    labels = {
      app     = "ecommerce-web"
      part-of = "ecommerce"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "ecommerce-web"
      }
    }

    template {
      metadata {
        labels = {
          app     = "ecommerce-web"
          part-of = "ecommerce"
        }
      }

      spec {
        container {
          name  = "web"
          image = "nginx:alpine" # Reemplaza con tu imagen real

          port {
            container_port = 80
          }

          env {
            name  = "PRODUCTS_API_URL"
            value = "http://products-api"
          }

          env {
            name  = "ORDERS_API_URL"
            value = "http://orders-api"
          }

          resources {
            limits = {
              cpu    = "300m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.products_api, kubernetes_service.orders_api]
}

resource "kubernetes_service" "ecommerce_web" {
  metadata {
    name      = "ecommerce-web"
    namespace = var.namespace
    labels = {
      app     = "ecommerce-web"
      part-of = "ecommerce"
    }
  }

  spec {
    selector = {
      app = "ecommerce-web"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# 7. Configuraciones de Ingress
resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "cert-manager.io/cluster-issuer"              = "selfsigned"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    }
  }

  spec {
    tls {
      hosts       = ["api.${var.domain_suffix}"]
      secret_name = "api-tls"
    }

    rule {
      host = "api.${var.domain_suffix}"
      http {
        path {
          path      = "/products"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.products_api.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/orders"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.orders_api.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.ingress_nginx,
    kubernetes_service.products_api,
    kubernetes_service.orders_api
  ]
}

resource "kubernetes_ingress_v1" "web_ingress" {
  metadata {
    name      = "web-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "cert-manager.io/cluster-issuer"              = "selfsigned"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
    }
  }

  spec {
    tls {
      hosts       = ["shop.${var.domain_suffix}"]
      secret_name = "web-tls"
    }

    rule {
      host = "shop.${var.domain_suffix}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.ecommerce_web.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx, kubernetes_service.ecommerce_web]
}
