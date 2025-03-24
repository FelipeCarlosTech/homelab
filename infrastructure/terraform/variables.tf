variable "environment" {
  description = "Entorno de despliegue (local, gcp)"
  type        = string
  default     = "local"
}

variable "infrastructure_namespace" {
  description = "Namespace for infrastructure components"
  type        = string
  default     = "infrastructure"
}

variable "databases_namespace" {
  description = "Namespace for database components"
  type        = string
  default     = "databases"
}

variable "microservices_namespace" {
  description = "Namespace for application microservices"
  type        = string
  default     = "microservices"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring components"
  type        = string
  default     = "monitoring"
}

variable "k8s_cluster_name" {
  description = "Nombre del cluster de Kubernetes"
  type        = string
  default     = "homelab-k3s"
}

variable "storage_class" {
  description = "Storage class por defecto para PVCs"
  type        = string
  default     = "local-path" # Storage class incluido por defecto en k3s
}

