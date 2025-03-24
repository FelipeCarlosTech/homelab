variable "namespaces" {
  description = "Namespace base para los recursos de Kubernetes"
  type        = map(string)
}

variable "storage_class" {
  description = "Storage class por defecto para PVCs"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (local, gcp)"
  type        = string
}

