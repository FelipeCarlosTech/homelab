output "kubernetes_namespaces" {
  description = "Los namespaces creados en el cluster de Kubernetes"
  value       = module.kubernetes_base.namespaces
}

output "storage_config" {
  description = "Configuración de almacenamiento"
  value       = module.storage.storage_config
}

output "network_config" {
  description = "Configuración de red"
  value       = module.networking.network_config
}