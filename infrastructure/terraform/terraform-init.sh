#!/bin/bash

set -e

# Directorio base
BASE_DIR=$(pwd)
ENV=${1:-local}  # Por defecto, usar el entorno local

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Inicializando Terraform para el entorno: ${ENV}${NC}"

if [ ! -d "environments/${ENV}" ]; then
    echo -e "${RED}Error: El entorno '${ENV}' no existe${NC}"
    echo "Entornos disponibles:"
    ls -1 environments/
    exit 1
fi

# Inicializar Terraform
cd "${BASE_DIR}/environments/${ENV}"
echo -e "${GREEN}Ejecutando terraform init...${NC}"
terraform init

# Validar la configuración
echo -e "${GREEN}Validando la configuración...${NC}"
terraform validate

# Mostrar plan de ejecución
echo -e "${GREEN}Generando plan de ejecución...${NC}"
terraform plan -out=tfplan

# Preguntar si quiere aplicar el plan
read -p "¿Desea aplicar el plan? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${GREEN}Aplicando plan...${NC}"
    terraform apply tfplan
    echo -e "${GREEN}¡Configuración aplicada con éxito!${NC}"
else
    echo -e "${YELLOW}Aplicación cancelada${NC}"
fi

# Limpiar
rm -f tfplan
cd "${BASE_DIR}"