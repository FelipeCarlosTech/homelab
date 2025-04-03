terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator-crds"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-operator-crds"
  version    = "0.1.1"
  namespace  = var.namespace

  # Este chart solo instala los CRDs sin el operador completo
  timeout = 300
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "22.6.7" # Versión estable actualizada
  namespace  = var.namespace

  values = [
    file("${path.module}/templates/prometheus-values.yaml")
  ]

  # Configuración específica
  set {
    name  = "server.persistentVolume.existingClaim"
    value = var.prometheus_storage.pvc_name
  }

  set {
    name  = "server.retention"
    value = var.retention_time
  }

  set {
    name  = "alertmanager.enabled"
    value = "true"
  }

  set {
    name  = "alertmanager.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Configuración de scrapeInterval global
  set {
    name  = "server.global.scrape_interval"
    value = var.scrape_interval
  }

  # Configuración para ServiceMonitor
  set {
    name  = "server.service.serviceMonitor.self.enabled"
    value = "true"
  }

  set {
    name  = "prometheus-pushgateway.enabled"
    value = "false"
  }

  set {
    name  = "kube-state-metrics.enabled"
    value = "true"
  }
}

# 2. Configmap para dashboards de Grafana
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = var.namespace
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "kubernetes-pods-dashboard.json" = file("${path.module}/templates/kubernetes-pods-dashboard.json")
    "microservices-dashboard.json"   = file("${path.module}/templates/microservices-dashboard.json")
    "node-exporter-dashboard.json"   = file("${path.module}/templates/node-exporter-dashboard.json")
  }

  depends_on = [helm_release.prometheus]
}

# 3. Despliegue de Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.58.7" # Versión estable actualizada
  namespace  = var.namespace
  depends_on = [helm_release.prometheus, kubernetes_config_map.grafana_dashboards]

  values = [
    file("${path.module}/templates/grafana-values.yaml")
  ]

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.existingClaim"
    value = var.grafana_storage.pvc_name
  }

  # Credenciales de administrador
  set {
    name  = "adminUser"
    value = var.grafana_admin.username
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin.password
  }

  # Configurar fuente de datos de Prometheus
  set {
    name  = "datasources.datasources\\.yaml.apiVersion"
    value = "1"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].name"
    value = "Prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].type"
    value = "prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].url"
    value = "http://prometheus-server.${var.namespace}.svc.cluster.local"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].access"
    value = "proxy"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].isDefault"
    value = "true"
  }

  # Configurar provider de dashboards
  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.apiVersion"
    value = "1"
  }

  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.providers[0].name"
    value = "default"
  }

  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.providers[0].orgId"
    value = "1"
  }

  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.providers[0].folder"
    value = "Kubernetes"
  }

  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.providers[0].type"
    value = "file"
  }

  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.providers[0].disableDeletion"
    value = "false"
  }

  set {
    name  = "dashboardProviders.dashboardproviders\\.yaml.providers[0].options.path"
    value = "/var/lib/grafana/dashboards/default"
  }

  # Configuración de sidecar para dashboards
  # set {
  #   name  = "sidecar.dashboards.enabled"
  #   value = "true"
  # }
  #
  # set {
  #   name  = "sidecar.dashboards.label"
  #   value = "grafana_dashboard"
  # }
  #
  # set {
  #   name  = "sidecar.dashboards.searchNamespace"
  #   value = var.namespace
  # }
}

# 4. Configuraciones de ServiceMonitor para microservicios
resource "kubectl_manifest" "products_api_service_monitor" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: products-api
  namespace: ${var.namespace}
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: products-api
  namespaceSelector:
    matchNames:
      - microservices
  endpoints:
  - port: http
    interval: 15s
    path: /metrics
YAML

  depends_on = [
    helm_release.prometheus,
    helm_release.prometheus_operator
  ]
}

resource "kubectl_manifest" "orders_api_service_monitor" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: orders-api
  namespace: ${var.namespace}
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: orders-api
  namespaceSelector:
    matchNames:
      - microservices
  endpoints:
  - port: http
    interval: 15s
    path: /metrics
YAML

  depends_on = [
    helm_release.prometheus,
    helm_release.prometheus_operator
  ]
}

# 5. Ingress para acceso a Grafana
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "cert-manager.io/cluster-issuer"              = "selfsigned"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "2m"
    }
  }

  spec {
    tls {
      hosts       = ["grafana.${var.domain_suffix}"]
      secret_name = "grafana-tls"
    }

    rule {
      host = "grafana.${var.domain_suffix}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.grafana]
}

# 6. Ingress para acceso a Prometheus (opcional)
resource "kubernetes_ingress_v1" "prometheus_ingress" {
  metadata {
    name      = "prometheus-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "cert-manager.io/cluster-issuer"              = "selfsigned"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "2m"
    }
  }

  spec {
    tls {
      hosts       = ["prometheus.${var.domain_suffix}"]
      secret_name = "prometheus-tls"
    }

    rule {
      host = "prometheus.${var.domain_suffix}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.prometheus]
}
