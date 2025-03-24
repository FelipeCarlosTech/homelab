resource "kubernetes_namespace" "namespaces" {
  for_each = var.namespaces

  metadata {
    name = each.value

    labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

