# Módulo EKS para crear un cluster de Kubernetes
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "homelab-eks"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  # Configuración de nodos
  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.medium"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
      
      disk_size = 50
    }
  }
  
  # Configura el acceso IAM
  # manage_aws_auth_configmap = true
  # aws_auth_roles = []
  # aws_auth_users = []
}

# Creamos una VPC para el cluster EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"
  
  name = "homelab-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  # Etiquetas requeridas para EKS
  tags = {
    "kubernetes.io/cluster/homelab-eks" = "shared"
  }
  
  public_subnet_tags = {
    "kubernetes.io/cluster/homelab-eks" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }
  
  private_subnet_tags = {
    "kubernetes.io/cluster/homelab-eks" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}

# Bucket S3 para almacenar el estado de Terraform (descomentar cuando estés listo para migrar)
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "tu-proyecto-homelab-tfstate"
#   
#   # Bloquear eliminación accidental
#   lifecycle {
#     prevent_destroy = true
#   }
# }
# 
# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# 
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }