module "homelab_local" {
  source = "../../"

  environment      = "local"
  k8s_cluster_name = "homelab-k3s"
  storage_class    = "local-path"
}

