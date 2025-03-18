terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0.0"
    # }
  }

  backend "local" {
    path = "terraform.tfstate"
  }

  # backend "s3" {
  #   bucket  = "homelab-tfstate"
  #   key     = "terraform/state"
  #   region  = "us-east-1"
  #   encrypt = true
  # }
}

