provider "kubernetes" {
  config_path = "~/.kube/config_nodezero"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config_nodezero"
  }
}

# provider "aws" {
#   region = "us-east-1"
#   # Las credenciales se configuran mediante variables de entorno AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY
#   # o mediante archivos ~/.aws/credentials
# }
