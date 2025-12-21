#!/bin/bash
#set -e

DEV_MODE=1

sudo systemctl start docker

# --- SECCIÓN DE LIMPIEZA DE CHOQUES ---
echo "🔍 Verificando conflictos de puertos..."

# 1. Detener MySQL nativo si está corriendo
if systemctl is-active --quiet mysql; then
    echo "🛑 Deteniendo servicio MySQL local para evitar choque en puerto 3306..."
    sudo systemctl stop mysql
fi

# 2. Liberar puerto 8080 (API) si está ocupado por un proceso huérfano
PORT_8080=$(sudo lsof -t -i:8080)
if [ ! -z "$PORT_8080" ]; then
    echo "💀 Matando proceso antiguo en puerto 8080 (PID: $PORT_8080)..."
    sudo kill -9 $PORT_8080
fi

# 3. Liberar puerto 3000 (Frontend) por si acaso
PORT_3000=$(sudo lsof -t -i:3000)
if [ ! -z "$PORT_3000" ]; then
    echo "💀 Matando proceso antiguo en puerto 3000 (PID: $PORT_3000)..."
    sudo kill -9 $PORT_3000
fi
# ---------------------------------------

echo "🚀 Iniciando el sistema TechLab..."

REPO_BACKEND="https://github.com/dmydna/simple-shop-api.git"
REPO_FRONTEND="https://github.com/dmydna/simple-shop.git"

# Función para clonar si no existe
check_and_clone() {
    if [ ! -d "$1" ]; then
        echo "📂 Carpeta $1 no encontrada. Clonando..."
        git clone "$2" "$1"
    else
        echo "✅ Carpeta $1 ya existe."
    fi
}



if [[ "$1" == "--reset" ]]; then
    echo "⚠️ MODO RESET: Borrando carpetas y contenedores..."
    docker compose down --remove-orphans
    rm -rf backend frontend
    check_and_clone "backend" "$REPO_BACKEND"
    check_and_clone "frontend" "$REPO_FRONTEND"

elif [[ "$1" == "--update" ]]; then
    echo "🔄 MODO UPDATE: Trayendo cambios de Git..."
    check_and_clone "backend" "$REPO_BACKEND"
    check_and_clone "frontend" "$REPO_FRONTEND"

    echo "📥 Actualizando Backend..."
    (cd backend && git fetch --all && git pull origin main)
    echo "📥 Actualizando Frontend..."
    (cd frontend && git fetch --all && git pull origin main)

elif [[ "$1" == "--kill" ]]; then
    echo "Stopping all services and removing orphaned containers..."
    # Ejecutamos down tanto para el archivo de producción como para el de dev
    # por si acaso alguno quedó activo.
    docker compose -f docker-compose.yml -f dev/docker-compose.dev.yml down --remove-orphans
    echo "✅ System cleaned. Exiting."
    exit 0

elif [[ "$1" == "--reset-api" ]]; then
     echo "reiniciado backend dev..."
     compose -f dev/docker-compose.dev.yml restart backend
    echo "✅ Reset ok. Exiting"
    exit 0

else
    echo "🚀 MODO ESTÁNDAR: Verificando carpetas locales..."
    check_and_clone "backend" "$REPO_BACKEND"
    check_and_clone "frontend" "$REPO_FRONTEND"
fi


if [[ $DEV_MODE -eq 1 ]]; then
    echo "🚀 Iniciando Entorno de DESARROLLO desde /dev..."
    
    # -f indica el archivo de configuración
    # Usamos docker-compose.dev.yml que ya tiene las rutas relativas
    docker compose -f dev/docker-compose-dev.yml up --build
else
    echo "🏗️ Iniciando Entorno de PRODUCCIÓN..."
    # Aquí iría tu comando estándar (ej. docker compose up -d)
    docker compose up --build
fi

#echo "🏗️ Construyendo..."
#docker compose up -d --build

echo "✅ Sistema levantado con éxito."
echo "---------------------------------------"
echo "Frontend: http://localhost:3000"
echo "Backend:  http://localhost:8080"
echo "H2 Console: http://localhost:8080/h2-console"
echo "---------------------------------------"
echo "💡 Usa 'docker compose logs -f' para ver los logs en tiempo real."
