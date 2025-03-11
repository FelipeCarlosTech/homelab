variable "environment" {
  description = "Entorno de despliegue (local, gcp)"
  type        = string
  default     = "local"
}

variable "namespace" {
  description = "Namespace base para los recursos de Kubernetes"
  type        = string
  default     = "homelab"
}

variable "k8s_cluster_name" {
  description = "Nombre del cluster de Kubernetes"
  type        = string
  default     = "homelab-k3s"
}

variable "storage_class" {
  description = "Storage class por defecto para PVCs"
  type        = string
  default     = "local-path"  # Storage class incluido por defecto en k3s
}