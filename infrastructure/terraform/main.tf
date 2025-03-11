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