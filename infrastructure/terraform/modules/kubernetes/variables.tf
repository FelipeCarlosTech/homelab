variable "namespaces" {
  description = "Map of namespaces to create"
  type        = map(string)
}

variable "k8s_cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

