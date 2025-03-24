module "kubernetes_base" {
  source = "./modules/kubernetes"

  # Crear todos los namespaces
  namespaces = {
    infrastructure = var.infrastructure_namespace
    databases      = var.databases_namespace
    microservices  = var.microservices_namespace
    monitoring     = var.monitoring_namespace
  }

  k8s_cluster_name = var.k8s_cluster_name
  environment      = var.environment
}

module "storage" {
  source = "./modules/storage"

  namespaces = {
    infrastructure = var.infrastructure_namespace
    databases      = var.databases_namespace
    microservices  = var.microservices_namespace
    monitoring     = var.monitoring_namespace
  }
  storage_class = var.storage_class
  environment   = var.environment

  depends_on = [module.kubernetes_base]
}

module "networking" {
  source = "./modules/networking"

  namespace   = var.infrastructure_namespace
  environment = var.environment

  depends_on = [module.kubernetes_base]
}

module "security" {
  source = "./modules/security"

  namespace   = var.infrastructure_namespace
  environment = var.environment

  depends_on = [module.kubernetes_base, module.networking]
}

module "databases" {
  source = "./modules/databases"

  namespace      = var.databases_namespace
  environment    = var.environment
  storage_class  = var.storage_class
  db_secret_name = module.security.security_config.db_secret

  depends_on = [
    module.kubernetes_base,
    module.storage,
    module.security
  ]
}

module "microservices" {
  source = "./modules/microservices"

  namespace               = var.microservices_namespace
  environment             = var.environment
  domain_suffix           = "homelab.local"
  db_secret_name          = module.security.security_config.db_secret
  enable_metrics          = true
  ingress_config_map_name = module.networking.network_config.ingress_config_map
  network_namespace       = var.infrastructure_namespace

  depends_on = [
    module.kubernetes_base,
    module.storage,
    module.networking,
    module.security,
  ]
}

