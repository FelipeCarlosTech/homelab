# Homelab DevOps Project 🏠

Este proyecto implementa una infraestructura completa de DevOps en un servidor local (homelab) utilizando tecnologías modernas como Ansible, Kubernetes (k3s), Docker, Terraform y microservicios.

## Estructura del Proyecto
```
homelab/
├── services/         # Microservicios (productos, usuarios, carritos)
├── infrastructure/   # Configuración de infraestructura
│   ├── ansible/      # Configuración automatizada del servidor
│   ├── terraform/    # Infraestructura como código
│   └── kubernetes/   # Manifiestos para k3s
└── docs/             # Documentación del proyecto
```
## Fases del Proyecto

1. Infraestructura Base (Ansible)
2. Infraestructura como Código (Terraform)
3. Kubernetes Base (k3s)
4. Observabilidad (Prometheus, Grafana)
5. CI/CD Base (Gitlab CI)
6. Microservicios (Products, Users, Cart)

## Comenzando

### Requisitos Previos

- Ubuntu Server 20.04 o superior
- Acceso SSH con clave pública
- Usuario con privilegios sudo

### Configuración Inicial

1. Actualiza el inventario en `infrastructure/ansible/inventory/homelab.ini`
2. Ejecuta el playbook de Ansible:

```bash
cd homelab/infrastructure/ansible/
ansible-playbook playbooks/site.yml
```