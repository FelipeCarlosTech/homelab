variable "namespace" {
  description = "Namespace base para los recursos de Kubernetes"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (local, gcp)"
  type        = string
}