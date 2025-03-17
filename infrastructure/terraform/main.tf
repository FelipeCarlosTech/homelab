module "kubernetes_base" {
  source = "./modules/kubernetes"

  namespace        = var.namespace
  k8s_cluster_name = var.k8s_cluster_name
  environment      = var.environment
}

module "storage" {
  source = "./modules/storage"

  namespace     = var.namespace
  storage_class = var.storage_class
  environment   = var.environment

  depends_on = [module.kubernetes_base]
}

module "networking" {
  source = "./modules/networking"

  namespace   = var.namespace
  environment = var.environment

  depends_on = [module.kubernetes_base]
}

module "security" {
  source = "./modules/security"

  namespace   = var.namespace
  environment = var.environment

  depends_on = [module.kubernetes_base, module.networking]
}

module "microservices" {
  source = "../../modules/microservices"

  namespace               = "microservices"
  environment             = var.environment
  domain_suffix           = "homelab.local"
  db_secret_name          = module.security.security_config.db_secret
  enable_metrics          = true
  ingress_config_map_name = module.networking.network_config.ingress_config_map # Nombre del ConfigMap existente
  network_namespace       = var.namespace                                       # Namespace donde está desplegado el ConfigMap

  depends_on = [
    module.kubernetes_base,
    module.storage,
    module.networking,
    module.security
  ]
}

