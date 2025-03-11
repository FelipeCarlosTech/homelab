output "storage_config" {
  description = "Configuración de almacenamiento persistente"
  value = {
    db_pvc_name        = kubernetes_persistent_volume_claim.db_data.metadata[0].name
    prometheus_pvc_name = kubernetes_persistent_volume_claim.prometheus_data.metadata[0].name
    grafana_pvc_name    = kubernetes_persistent_volume_claim.grafana_data.metadata[0].name
  }
}