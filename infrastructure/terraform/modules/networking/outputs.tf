output "network_config" {
  description = "Configuración de red"
  value = {
    ingress_config_map = kubernetes_config_map.ingress_nginx_config.metadata[0].name
    network_policies = {
      default_deny = kubernetes_network_policy.default_deny_ingress.metadata[0].name
      allow_ingress = kubernetes_network_policy.allow_ingress_controller.metadata[0].name
    }
  }
}