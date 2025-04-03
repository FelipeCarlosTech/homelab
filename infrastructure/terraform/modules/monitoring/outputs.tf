output "monitoring_endpoints" {
  description = "Endpoints de monitoreo"
  value = {
    prometheus          = "https://prometheus.${var.domain_suffix}"
    grafana             = "https://grafana.${var.domain_suffix}"
    prometheus_internal = "http://prometheus-server.${var.namespace}.svc.cluster.local"
    alertmanager        = "http://prometheus-alertmanager.${var.namespace}.svc.cluster.local"
  }
}

output "grafana_credentials" {
  description = "Credenciales de acceso para Grafana"
  value = {
    username = var.grafana_admin.username
    password = nonsensitive(var.grafana_admin.password)
  }
  sensitive = false
}

output "prometheus_service_monitors" {
  description = "ServiceMonitors configurados para el monitoreo"
  value = {
    products_api = kubectl_manifest.products_api_service_monitor.name
    orders_api   = kubectl_manifest.orders_api_service_monitor.name
  }
}
