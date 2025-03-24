output "namespaces" {
  description = "Mapa de todos los namespaces creados en el cluster"
  value = {
    for key, _ in var.namespaces :
    key => kubernetes_namespace.namespaces[key].metadata[0].name
  }
}

output "namespace_names" {
  description = "Lista simple con los nombres de todos los namespaces creados"
  value       = [for ns in kubernetes_namespace.namespaces : ns.metadata[0].name]
}

output "namespaces_labels" {
  description = "Mapa con los labels asignados a cada namespace"
  value = {
    for key, _ in var.namespaces :
    key => kubernetes_namespace.namespaces[key].metadata[0].labels
  }
}

