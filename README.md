# Homelab 🏠

A complete homelab infrastructure management system using Terraform, Ansible, and K3s for Kubernetes orchestration.

## Overview

This project provides a full infrastructure-as-code solution for managing a homelab environment. It leverages:

- **Terraform** for infrastructure provisioning
- **Ansible** for configuration management
- **K3s** as a lightweight Kubernetes distribution

## Components

### Terraform Modules

- **kubernetes_base**: Core Kubernetes infrastructure setup
- **storage**: Persistent volume management for Kubernetes
- **networking**: Network configuration including ingress controllers
- **security**: Security implementations like cert-manager and network policies
- **databases**: Database services including PostgreSQL
- **microservices**: Microservices deployment with ingress configuration

### Ansible Components

Automates server configuration and K3s deployment across the cluster.

## Prerequisites

- Terraform v1.0+
- Ansible v2.10+
- Linux/Unix-based systems for hosting K3s
- SSH access to all target machines
- Sufficient hardware resources (CPU/RAM/Storage)

## Installation

### Initial Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/felipecarlos/homelab.git
   cd homelab
   ```

2. Configure Terraform variables:

   ```bash
   cp infrastructure/terraform/terraform.tfvars.example infrastructure/terraform/terraform.tfvars
   # Edit the terraform.tfvars file with your specific configuration
   ```

3. Set up Ansible inventory:

   ```bash
   cp ansible/inventory/hosts.example ansible/inventory/hosts
   # Edit the hosts file with your server details
   ```

### Deployment

1. Initialize and deploy infrastructure with Terraform:

   ```bash
   # Option 1: Manual initialization
   cd infrastructure/terraform
   terraform init
   terraform plan
   terraform apply
   
   # Option 2: Using the initialization script
   ./infrastructure/terraform/terraform-init.sh [environment]
   ```

2. Configure servers with Ansible:

   ```bash
   cd ansible
   ansible-playbook main.yml
   
   # To configure a basic homelab server
   ansible-playbook playbooks/site.yml
   ```

## Project Structure

```
homelab/
├── .gitignore                  # Git ignore patterns
├── README.md                   # This file
├── infrastructure/             # Infrastructure as code
│   ├── ansible/                # Ansible configuration
│   │   ├── inventory/          # Server inventory
│   │   ├── roles/              # Ansible roles
│   │   └── playbooks/          # Specific playbooks
│   │       └── site.yml        # Base server setup playbook
│   └── terraform/              # Terraform configuration
│       ├── main.tf             # Main configuration file
│       ├── variables.tf        # Variable definitions
│       ├── terraform-init.sh   # Terraform initialization script
│       ├── environments/       # Environment-specific configs
│       └── modules/            # Terraform modules
│           ├── kubernetes/     # K3s base setup
│           ├── storage/        # Storage configuration
│           ├── networking/     # Network setup
│           ├── security/       # Security configuration
│           ├── databases/      # Database services
│           │   └── templates/  # Database configuration templates
│           └── microservices/  # Microservices deployment
│               └── templates/  # Microservices configuration templates
```

## Usage

### Terraform Management

Apply changes to specific modules:

```bash
terraform apply -target=module.storage

# For environment-specific deployment
./terraform-init.sh production
```

### Ansible Operations

Run specific tasks:

```bash
ansible-playbook playbooks/upgrade-k3s.yml

# Deploy base homelab server
ansible-playbook playbooks/site.yml
```

### K3s Cluster Management

Access your Kubernetes cluster:

```bash
export KUBECONFIG=/path/to/kubeconfig.yaml
kubectl get nodes
```

### Database Management

The databases module provides PostgreSQL deployment with:

- Resource limits configuration
- Custom environment variables
- User and database setup
- Version selection (currently using PostgreSQL 15.3)

Example configuration can be found in `infrastructure/terraform/modules/databases/templates/postgresql-values.yaml`.

### Microservices Configuration

The microservices module includes:

- Ingress controller configuration
- HTTP connection upgrade support

## Configuration

Key configuration files:

- `infrastructure/terraform/variables.tf`: Define infrastructure variables
- `ansible/inventory/group_vars/`: Group-specific variables
- `ansible/inventory/host_vars/`: Host-specific variables
- `infrastructure/terraform/modules/databases/templates/`: Database templates
- `infrastructure/terraform/modules/microservices/templates/`: Microservices templates

## Troubleshooting

Common issues:

- Terraform state lock: `terraform force-unlock <ID>`
- Ansible connectivity: Check SSH keys and network connectivity
- K3s issues: Check logs with `journalctl -u k3s`
- Environment selection: Ensure using the correct environment with terraform-init.sh

## Backup & Recovery

Backup strategies:

- Terraform: Regular state backup
- K3s: Etcd backup and snapshot management
- Data: Persistent volume backups
- PostgreSQL: Database dumps and volume backups

## Security Notes

- Sensitive values are stored in vault files
- Credentials are never committed to Git
- Regular updates are applied to all components
- SSH root login and password authentication disabled by default
- UFW firewall automatically configured

