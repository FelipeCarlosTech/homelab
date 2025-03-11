variable "namespace" {
  description = "Namespace base para los recursos de Kubernetes"
  type        = string
}

variable "k8s_cluster_name" {
  description = "Nombre del cluster de Kubernetes"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (local, gcp)"
  type        = string
}