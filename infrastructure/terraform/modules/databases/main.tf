resource "helm_release" "postgresql" {
  name       = "postgresql"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "12.5.7"

  values = [
    file("${path.module}/templates/postgresql-values.yaml")
  ]

  set {
    name  = "auth.existingSecret"
    value = var.db_secret_name
  }

  set {
    name  = "primary.persistence.existingClaim"
    value = "db-data"
  }
}

