output "namespaces" {
  description = "Los namespaces creados en el cluster"
  value = {
    homelab      = kubernetes_namespace.homelab.metadata[0].name
    monitoring   = kubernetes_namespace.monitoring.metadata[0].name
    microservices = kubernetes_namespace.microservices.metadata[0].name
  }
}