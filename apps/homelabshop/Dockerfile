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

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
