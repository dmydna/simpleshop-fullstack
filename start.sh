#!/bin/bash
#set -e
source .env

pre_check() {
    # 1. Validar .env
    if [ ! -f .env ]; then
        echo "❌ Error: Archivo .env no encontrado en la raíz."
        exit 1
    fi

    # 2. Sincronizar configuraciones
    echo "📂 Sincronizando configuraciones..."
    mkdir -p .config # Asegura que la carpeta existe
    cp -u .env .config/.env 2>/dev/null || cp .env .config/.env
    cp -u .env backend/.env 2>/dev/null || cp .env backend/.env
    cp -u .env frontend/.env 2>/dev/null || cp .env frontend/.env

    # 3. Docker Engine check
    if ! docker info >/dev/null 2>&1; then
        echo "🐳 Iniciando motor de Docker..."
        sudo systemctl start docker && sleep 3
    fi

    # 4. Limpieza de choques (MySQL nativo y Puertos)
    if lsof -Pi :3306 -sTCP:LISTEN -t >/dev/null && systemctl is-active --quiet mysql; then
        echo "🛑 Deteniendo MySQL local para liberar puerto 3306..."
        sudo systemctl stop mysql
    fi

    echo "🔍 Liberando puertos: $PORT_BACKEND, $PORT_DATABASE, $PORT_FRONTEND"
    for puerto in ${PORT_BACKEND} ${PORT_DATABASE} ${PORT_FRONTEND}; do
        pid=$(lsof -t -i:$puerto)
        [ ! -z "$pid" ] && (kill -9 $pid 2>/dev/null || sudo kill -9 $pid)
    done
}
# ---------------------------------------



echo "🚀 Iniciando el sistema TechLab..."

# --- CONFIGURACIÓN ---

DB_CONTAINER="config-db-1"
FRONT_CONTAINER="config-frontend-1"
BACK_CONTAINER="config-backend-1"
DB_PASSWORD=${DB_PASSWORD}
DEV_MODE=${DEV_MODE}
REPO_BACKEND="https://github.com/dmydna/simple-shop-api.git"
REPO_FRONTEND="https://github.com/dmydna/simple-shop.git"
FILE_DEV=".config/docker-compose-dev.yml"
FILE_PROD="docker-compose.yml"
ENV_FILE="--env-file .env"


# Función para clonar si no existe
check_and_clone() {
    if [ ! -d "$1" ]; then
        echo "📂 Clonando $1..."
        git clone "$2" "$1"
    fi
}


print_help() {
     echo "✅ Sistema levantado con éxito."
     echo "---------------------------------------"
     echo "Frontend: http://localhost:${PORT_FRONTEND}"
     echo "Backend:  http://localhost:${PORT_BACKEND}"
     echo "H2 Console: http://localhost:${PORT_BACKEND}/h2-console"
     echo "---------------------------------------"
     echo "💡 Usa 'docker compose logs -f' para ver los logs en tiempo real."
}

# Función para limpiar Docker de raíz
docker_clean() {
    echo "🧹 Limpiando Docker (Volúmenes y Huérfanos)..."
    docker compose -f $FILE_DEV down -v --remove-orphans
    docker compose -f $FILE_PROD down -v --remove-orphans
}

# --- LÓGICA DE ARGUMENTOS ---
case "$1" in
    --refresh-docker)
       # usar si se agrega nuevas librerias en front/backend
        docker compose up --build
        exit 0
        ;;
    --hard-reset)
        echo "🔥 DOCKER DESTROY MODE: Borrando todo..."
        pre_check
        docker compose -f $FILE_DEV down -v --rmi all --remove-orphans
        exit 0
        ;;
    --kill)
        pre_check
        docker_clean
        exit 0
        ;;
    --db)
       docker exec -it $DB_CONTAINER bash
       exit 0
       ;;
    --clean-db)
      echo "⚠️ CLEAN DATABASE: Limpiando Bases de Datos..."
      docker exec config-db-1 mysql -u root -p "${DB_PASSWORD}" -e "DROP DATABASE nombre_de_tu_bd; CREATE DATABASE nombre_de_tu_bd;"
      exit 0
      ;;

    --logs-frontend  | --logs-backend)
      SERVICE=${1#--logs-}
      docker compose -f $FILE_DEV logs $SERVICE
      exit 0
      ;;
    --log-frontend)
      docker logs $FRONT_CONTAINER
      exit 0
      ;;
    --reset)
        echo "⚠️ RESET: Borrando carpetas y contenedores..."
        pre_check
        docker_clean
        rm -rf backend frontend
        ;;
    --update)
        echo "🔄 UPDATE: Sincronizando Git..."
        pre_check
        for dir in backend frontend; do
            (cd $dir && git fetch --all && git pull origin main)
        done
        ;;
    --reset-backend | --reset-frontend)
        SERVICE=${1#--reset-} # Extrae 'api' o 'frontend'
        echo "♻️ Reiniciando $SERVICE..."
        docker compose -f $FILE_DEV restart $SERVICE
        exit 0
        ;;
    --help)
        print_help
        exit 0
        ;;
    --backend-only)
        echo "🚀 Iniciando solo BACKEND..."
        pre_check
        # Levanta el servicio 'api' y sus dependencias (como la DB) en segundo plano
        docker compose -f $FILE_DEV up -d backend
        docker compose -f $FILE_DEV logs -f backend
        exit 0
        ;;
    --frontend-only)
        echo "💻 Iniciando solo FRONTEND..."
        pre_check
        # Levanta solo el servicio 'frontend'
        docker compose -f $FILE_DEV up -d frontend
        docker compose -f $FILE_DEV logs -f frontend
        exit 0
        ;;
    --clear-db)
        echo "🗑️ Borrando bases de datos y volúmenes..."
        pre_check
        # down -v borra los volúmenes definidos en el docker-compose
        docker compose -f $FILE_DEV down -v
        echo "✅ Base de datos eliminada. Usa el comando de inicio normal para recrearla."
        exit 0
        ;;
    --pre-check)
        pre_check
        exit 0
        ;;
esac


# --- FLUJO ESTÁNDAR ---
echo "🚀 Verificando repositorios..."
check_and_clone "backend" "$REPO_BACKEND"
check_and_clone "frontend" "$REPO_FRONTEND"

if [[ $DEV_MODE -eq 1 ]]; then
    echo "🚀 Iniciando Entorno de DESARROLLO desde /dev..."
    docker compose ${ENV_FILE} -f ${FILE_DEV} up --build
else
    echo "🏗️ Iniciando Entorno de PRODUCCIÓN..."
    docker compose up --build
fi


print_help
