#!/bin/bash
#source .env

# --- CONFIGURACIÓN DE COLORES ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Cargamos variables de entorno si existe el archivo
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}❌ Error: Archivo .env no encontrado.${NC}"
    exit 1
fi

# Variables de contenedores (Mejorado: usa prefijo de proyecto si existe)
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-"techlab"}
DB_CONTAINER="${COMPOSE_PROJECT_NAME}-db-1"
FILE_DEV=".config/docker-compose-dev.yml"
FILE_PROD="docker-compose.yml"

# --- FUNCIONES DE APOYO ---

pre_check() {
    echo -e "${BLUE}🔍 Ejecutando chequeos preventivos...${NC}"
    
    # 1. Sincronizar .env a los submodulos
    for dir in "backend" "frontend" ".config"; do
        if [ -d "$dir" ]; then
            cp .env "$dir/.env" 2>/dev/null && echo -e "  ✅ .env sincronizado en $dir"
        fi
    done

    # 2. Docker Engine check
    if ! docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}🐳 Iniciando motor de Docker...${NC}"
        sudo systemctl start docker && sleep 3
    fi

    # 3. Liberar puertos
    local ports=(${PORT_BACKEND} ${PORT_DATABASE} ${PORT_FRONTEND})
    for puerto in "${ports[@]}"; do
        pid=$(lsof -t -i:$puerto)
        if [ ! -z "$pid" ]; then
            echo -e "${YELLOW}⚠️ Liberando puerto $puerto...${NC}"
            kill -9 $pid 2>/dev/null || sudo kill -9 $pid
        fi
    done
}

print_msg() {
     echo -e "\n${GREEN}======================================="
     echo -e "🚀 Sistema TechLab en línea"
     echo -e "=======================================${NC}"
     echo -e "🌐 Frontend:   ${BLUE}http://localhost:${PORT_FRONTEND}${NC}"
     echo -e "⚙️  Backend:    ${BLUE}http://localhost:${PORT_BACKEND}${NC}"
     echo -e "📊 Database:   ${BLUE}Puerto ${PORT_DATABASE}${NC}"
     echo -e "---------------------------------------"
     echo -e "💡 Tips: Usa ${YELLOW}./start.sh --logs-backend${NC} para ver logs."
}

show_help() {
    echo -e "${BLUE}Modo de uso:${NC} ./start.sh [opción]"
    echo -e ""
    echo -e "🚀 ${GREEN}Servicios:${NC}"
    echo -e "  (sin args)        Levanta todo el sistema (según DEV_MODE)"
    echo -e "  --run-backend     Levanta solo el backend + dependencias"
    echo -e "  --run-frontend    Levanta solo el frontend"
    echo -e ""
    echo -e "🛠️  ${YELLOW}Mantenimiento:${NC}"
    echo -e "  --db              Entra a la consola MySQL"
    echo -e "  --clean-db        Resetea la base de datos (DROP/CREATE)"
    echo -e "  --update          Actualiza submódulos Git"
    echo -e "  --refresh-docker  Reconstruye imágenes desde cero"
    echo -e ""
    echo -e "🛑 ${RED}Peligro:${NC}"
    echo -e "  --kill            Detiene y elimina contenedores y volúmenes"
    echo -e "  --hard-reset      Borra TODO (imágenes, volúmenes, carpetas)"
}

# --- LÓGICA DE ARGUMENTOS ---

case "$1" in
    --db)
        echo -e "${BLUE}📂 Accediendo a la base de datos...${NC}"
        docker exec -it -e MYSQL_PWD="$DB_PASSWORD" "$DB_CONTAINER" mysql -u root -p"$DB_PASSWORD" "$DB_NAME"
        exit 0
        ;;
    --clean-db)
        echo -e "${RED}⚠️  Limpiando base de datos $DB_NAME...${NC}"
        docker exec -it -e MYSQL_PWD="$DB_PASSWORD" "$DB_CONTAINER" mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;"
        echo -e "${GREEN}✅ Base de datos reseteada.${NC}"
        exit 0
        ;;
    --refresh-docker)
        pre_check
        docker compose -f $FILE_DEV up --build --force-recreate
        exit 0
        ;;
    --kill)
        pre_check
        docker compose -f $FILE_DEV down -v --remove-orphans
        echo -e "${GREEN}✅ Limpieza completada.${NC}"
        exit 0
        ;;
    --update)
        echo -e "${BLUE}🔄 Actualizando submódulos...${NC}"
        git submodule update --init --recursive --remote
        exit 0
        ;;
    --help|-h)
        show_help
        exit 0
        ;;
    *)
        if [ ! -z "$1" ] && [[ "$1" != --* ]]; then
             echo -e "${RED}Opción no reconocida: $1${NC}"
             show_help
             exit 1
        fi
        ;;
esac

# --- FLUJO ESTÁNDAR ---
pre_check

echo -e "${BLUE}🚀 Verificando submódulos Git...${NC}"
git submodule update --init --recursive

if [[ "$DEV_MODE" == "1" ]]; then
    echo -e "${YELLOW}🚧 Iniciando en modo DESARROLLO...${NC}"
    docker compose -f "$FILE_DEV" up --build -d
else
    echo -e "${GREEN}📦 Iniciando en modo PRODUCCIÓN...${NC}"
    docker compose -f "$FILE_PROD" up --build -d
fi

print_msg
