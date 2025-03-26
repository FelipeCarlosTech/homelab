# Configuraciones de seguridad básicas para el cluster
# Secretos para microservicios y componentes

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = "databases"
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "ecommerce-db"
    }
  }

  data = {
    username          = "ecommerce_user"
    password          = "change_me_in_production" # En un entorno real, usar variables o vault
    database          = "ecommerce"
    postgres-password = "change_me_in_production"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "db_credentials_microservices" {
  metadata {
    name      = "db-credentials"
    namespace = "microservices"
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      app         = "ecommerce-db"
    }
  }

  # Mismos datos que el secreto anterior
  data = {
    username          = "ecommerce_user"
    password          = "change_me_in_production"
    database          = "ecommerce"
    postgres-password = "change_me_in_production"
  }

  type = "Opaque"
}

resource "kubernetes_role" "microservices_role" {
  metadata {
    name      = "microservices-role"
    namespace = "microservices"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "microservices_binding" {
  metadata {
    name      = "microservices-binding"
    namespace = "microservices"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.microservices_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "microservices"
  }
}
