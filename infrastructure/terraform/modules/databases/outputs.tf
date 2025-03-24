output "database_info" {
  value = {
    postgresql_service = "postgresql.${var.namespace}.svc.cluster.local"
    postgresql_port    = 5432
  }
}
