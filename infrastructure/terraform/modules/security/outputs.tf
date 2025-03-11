output "security_config" {
  description = "Configuración de seguridad"
  value = {
    db_secret = kubernetes_secret.db_credentials.metadata[0].name
    role_name = kubernetes_role.microservices_role.metadata[0].name
  }
}