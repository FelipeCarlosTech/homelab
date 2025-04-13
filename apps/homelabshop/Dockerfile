# Etapa de compilación
FROM --platform=linux/amd64 node:16-alpine as build

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .
RUN npm run build

# Etapa de producción
FROM --platform=linux/amd64 nginx:alpine

# Copiar la build de React
COPY --from=build /app/build /usr/share/nginx/html

# Configuración de Nginx para SPA (Single Page Application)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
