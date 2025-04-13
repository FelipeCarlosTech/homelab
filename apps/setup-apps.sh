#!/bin/bash

# Directorio base
BASE_DIR=$(pwd)

# Colores para salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#Definir Registry
NODEZERO_IP="192.168.1.22"
REGISTRY="$NODEZERO_IP:5000"

# 0. Verificar y configurar registry Docker en nodezero:5000
echo -e "${YELLOW}Verificando Docker Registry en nodezero:5000${NC}"

# Intentar conectar con el registry para ver si ya está funcionando
if curl -s -f http://nodezero:5000/v2/ >/dev/null 2>&1; then
  echo -e "${GREEN}Registry ya está corriendo en nodezero:5000${NC}"
else
  echo -e "${YELLOW}Registry no encontrado. Configurando registry en nodezero...${NC}"

  # Usar SSH para conectarse a nodezero y configurar el registry
  ssh nodezero "docker ps | grep -q registry || docker run -d -p 5000:5000 --restart=always --name registry registry:2"

  # Esperar a que el registry esté disponible
  echo "Esperando a que el registry esté disponible..."
  for i in {1..10}; do
    if curl -s -f http://nodezero:5000/v2/ >/dev/null 2>&1; then
      echo -e "${GREEN}Registry ahora está disponible en nodezero:5000${NC}"
      break
    fi
    if [ $i -eq 10 ]; then
      echo -e "${RED}No se pudo conectar al registry después de varios intentos${NC}"
      exit 1
    fi
    echo "Intentando conectar, intento $i de 10..."
    sleep 3
  done
fi
#
# # 1. Asegurar que podemos acceder a la base de datos PostgreSQL
# echo -e "${YELLOW}Aplicando migraciones a la base de datos${NC}"
#
# # Obtener credenciales de la base de datos desde el secreto de Kubernetes
# DB_USER=$(kubectl get secret -n databases db-credentials -o jsonpath='{.data.username}' | base64 --decode)
# DB_PASS=$(kubectl get secret -n databases db-credentials -o jsonpath='{.data.password}' | base64 --decode)
# DB_NAME=$(kubectl get secret -n databases db-credentials -o jsonpath='{.data.database}' | base64 --decode)
#
# # Port-forward al servicio de PostgreSQL
# echo "Iniciando port-forward a PostgreSQL..."
# kubectl port-forward -n databases svc/postgresql 5432:5432 &
# PF_PID=$!
#
# # Esperar a que el port-forward esté listo
# sleep 5
#
# # Aplicar migraciones
# echo "Aplicando migraciones SQL..."
# PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -f ${BASE_DIR}/database/schema.sql
#
# # Detener el port-forward
# kill $PF_PID
# wait $PF_PID 2>/dev/null
#
# 2. Construir imágenes Docker
echo -e "${YELLOW}Construyendo imágenes Docker${NC}"

# Products API
echo -e "${GREEN}Construyendo imagen products-api...${NC}"
cd ${BASE_DIR}/products-api
docker build -t $REGISTRY/products-api:latest .
docker push $REGISTRY/products-api:latest

# Orders API
echo -e "${GREEN}Construyendo imagen orders-api...${NC}"
cd ${BASE_DIR}/orders-api
docker build -t $REGISTRY/orders-api:latest .
docker push $REGISTRY/orders-api:latest

# HomelabShop Frontend
echo -e "${GREEN}Construyendo imagen homelabshop...${NC}"
cd ${BASE_DIR}/homelabshop
docker build -t $REGISTRY/homelabshop:latest .
docker push $REGISTRY/homelabshop:latest

cd ${BASE_DIR}
echo -e "${GREEN}Todas las imágenes construidas y publicadas correctamente${NC}"

# 3. Reiniciar deployments para aplicar los cambios
echo -e "${YELLOW}Reiniciando deployments para aplicar cambios...${NC}"
kubectl rollout restart deployment -n microservices products-api
kubectl rollout restart deployment -n microservices orders-api
kubectl rollout restart deployment -n microservices ecommerce-web

echo -e "${GREEN}¡Aplicaciones desplegadas correctamente!${NC}"
echo "Podrás acceder a la tienda en https://shop.homelab.local"
