module "homelab_local" {
  source = "../../"
  
  environment      = "local"
  namespace        = "homelab"
  k8s_cluster_name = "homelab-k3s"
  storage_class    = "local-path"
}