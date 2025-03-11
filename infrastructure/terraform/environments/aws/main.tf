module "homelab_aws" {
  source = "../../"
  
  environment      = "aws"
  namespace        = "homelab"
  k8s_cluster_name = "homelab-eks"  # Nombre del cluster en EKS
  storage_class    = "gp3"          # Storage class de AWS (gp3 es el SSD estándar)
}