output "microservices_config" {
  description = "Configuración de los microservicios"
  value = {
    api_url          = "https://api.${var.domain_suffix}"
    website_url      = "https://shop.${var.domain_suffix}"
    db_host          = "postgres.${var.namespace}.svc.cluster.local"
    products_api_url = "http://products-api.${var.namespace}.svc.cluster.local"
    orders_api_url   = "http://orders-api.${var.namespace}.svc.cluster.local"
  }
}

output "ingress_controller" {
  description = "Configuración del controlador de ingress"
  value = {
    name      = helm_release.ingress_nginx.name
    namespace = helm_release.ingress_nginx.namespace
  }
}

output "api_services" {
  description = "Servicios de API desplegados"
  value = {
    products = kubernetes_service.products_api.metadata[0].name
    orders   = kubernetes_service.orders_api.metadata[0].name
  }
}
