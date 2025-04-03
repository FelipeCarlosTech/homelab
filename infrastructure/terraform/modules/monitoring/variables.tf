variable "namespace" {
  description = "Namespace para componentes de monitoreo"
  type        = string
  default     = "monitoring"
}

variable "environment" {
  description = "Entorno de despliegue (local, aws)"
  type        = string
}

variable "domain_suffix" {
  description = "Sufijo de dominio para servicios de monitoreo"
  type        = string
  default     = "homelab.local"
}

variable "prometheus_storage" {
  description = "Configuración de almacenamiento para Prometheus"
  type = object({
    pvc_name = string
  })
  default = {
    pvc_name = "prometheus-data"
  }
}

variable "grafana_storage" {
  description = "Configuración de almacenamiento para Grafana"
  type = object({
    pvc_name = string
  })
  default = {
    pvc_name = "grafana-data"
  }
}

variable "grafana_admin" {
  description = "Credenciales de admin para Grafana"
  type = object({
    username = string
    password = string
  })
  default = {
    username = "admin"
    password = "homelab-admin" # En producción usar secrets
  }
  sensitive = true
}

variable "retention_time" {
  description = "Tiempo de retención para datos de Prometheus"
  type        = string
  default     = "15d" # 15 días
}

variable "scrape_interval" {
  description = "Intervalo de scraping para Prometheus"
  type        = string
  default     = "30s"
}

variable "network_namespace" {
  description = "Namespace donde se encuentra la configuración de red"
  type        = string
  default     = "infrastructure"
}
