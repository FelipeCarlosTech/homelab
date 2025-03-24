variable "namespace" {
  description = "Namespace para los microservicios"
  type        = string
  default     = "microservices"
}

variable "environment" {
  description = "Entorno de despliegue (local, aws)"
  type        = string
}

variable "domain_suffix" {
  description = "Sufijo de dominio para los servicios"
  type        = string
  default     = "homelab.local"
}

variable "db_secret_name" {
  description = "Nombre del secreto que contiene las credenciales de la BD"
  type        = string
  default     = "db-credentials"
}

variable "enable_metrics" {
  description = "Habilitar métricas para Prometheus"
  type        = bool
  default     = false
}

variable "ingress_config_map_name" {
  description = "Nombre del ConfigMap en el módulo de networking con la configuración del ingress"
  type        = string
  default     = "ingress-nginx-config"
}

variable "network_namespace" {
  description = "Namespace donde se encuentra la configuración de red"
  type        = string
  default     = "homelab"
}

