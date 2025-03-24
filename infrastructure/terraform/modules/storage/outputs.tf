output "persistent_volume_claim_names" {
  description = "Names of all the PVCs created by this module"
  value       = { for k, v in kubernetes_persistent_volume_claim.pvc : k => v.metadata[0].name }
}

output "persistent_volume_claims_by_namespace" {
  description = "Map of PVCs organized by namespace"
  value = {
    for namespace in distinct([for pvc in kubernetes_persistent_volume_claim.pvc : pvc.metadata[0].namespace]) :
    namespace => {
      for k, v in kubernetes_persistent_volume_claim.pvc :
      k => v if v.metadata[0].namespace == namespace
    }
  }
}

output "storage_details" {
  description = "Storage details for each PVC"
  value = {
    for k, v in kubernetes_persistent_volume_claim.pvc :
    k => {
      namespace     = v.metadata[0].namespace
      access_modes  = v.spec[0].access_modes
      storage_class = v.spec[0].storage_class_name
      storage_size  = v.spec[0].resources[0].requests.storage
    }
  }
}

output "pvc_ids" {
  description = "The IDs of the created PVCs"
  value       = { for k, v in kubernetes_persistent_volume_claim.pvc : k => v.id }
}

output "storage_config" {
  description = "Complete storage configuration for reference in other modules"
  value = {
    pvcs = kubernetes_persistent_volume_claim.pvc
    pvc_details = { for k, v in kubernetes_persistent_volume_claim.pvc : k => {
      name         = v.metadata[0].name
      namespace    = v.metadata[0].namespace
      storage_size = v.spec[0].resources[0].requests.storage
      access_modes = v.spec[0].access_modes
    } }
    pvc_names = { for k, v in kubernetes_persistent_volume_claim.pvc : k => v.metadata[0].name }
  }
}

