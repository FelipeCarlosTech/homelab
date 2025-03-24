variable "namespace" {
  description = "Kubernetes namespace for database deployments"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "storage_class" {
  description = "Storage class for database persistence"
  type        = string
}

variable "db_secret_name" {
  description = "Name of the secret containing database credentials"
  type        = string
}
