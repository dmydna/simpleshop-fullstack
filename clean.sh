#!/bin/bash

echo "🛑 Deteniendo contenedores y eliminando volúmenes..."
# -v borra los volúmenes (maven_data, db_data, etc)
# --remove-orphans limpia contenedores viejos que ya no están en el compose
docker compose down -v --remove-orphans

echo "🧹 Limpiando caché de construcción de Docker..."
# Esto borra el caché de build que no se usa, liberando espacio
docker builder prune -f

echo "🔄 ¿Deseas borrar también las imágenes del proyecto para un build limpio? (s/n)"
read -r response
if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
    echo "🗑️ Borrando imágenes del proyecto..."
    # Borra imágenes que contengan el nombre de tu carpeta actual
    docker images | grep $(basename "$PWD") | awk '{print $3}' | xargs docker rmi -f
fi

echo "✅ Entorno limpio. Puedes ejecutar: docker compose up --build"
