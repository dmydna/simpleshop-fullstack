#!/bin/bash

# --- CONFIGURACIÓN DE COLORES ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Carga variables de entorno si existe el archivo
if [ -f .env ]; then
    set -a            # Activa el export automático de variables
    source .env
    set +a            # Desactiva el export automático
else
    echo -e "${RED}❌ Error: Archivo .env no encontrado.${NC}"
    exit 1
fi



# Variables de contenedores (Mejorado: usa prefijo de proyecto si existe)
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-"techlab"}
DB_CONTAINER="${COMPOSE_PROJECT_NAME}-db-1"
BACK_CONTAINER="${COMPOSE_PROJECT_NAME}-backend-1"
FRONT_CONTAINER="${COMPOSE_PROJECT_NAME}-frontend-1"
FILE_DEV=".config/docker-compose-dev.yml"
FILE_PROD="docker-compose.yml"



MSG_KILL_ALL="⚠️  ADVERTENCIA: \n Se van a BORRAR TODOS los datos persistentes (volumes, contenedores, redes). \n"
MSG_KILL_DB="⚠️  ADVERTENCIA: \n Se van a BORRAR TODOS los datos de la base de datos.\n"

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



MSG_Success() {
     echo -e "\n${GREEN}======================================="
     echo -e "🚀 Sistema TechLab en línea"
     echo -e "=======================================${NC}"
     echo -e "🌐 Frontend:   ${BLUE}http://localhost:${PORT_FRONTEND}${NC}"
     echo -e "⚙️  Backend:    ${BLUE}http://localhost:${PORT_BACKEND}${NC}"
     echo -e "📊 Database:   ${BLUE}Puerto ${PORT_DATABASE}${NC}"
     echo -e "---------------------------------------"
     echo -e "💡 Tips: Usa ${YELLOW}./start.sh --logs-backend${NC} para ver logs."
}

MSG_Error(){
     echo -e "\n${RED}❌ Error: Algunos servicios no están corriendo.${NC}"
     echo -e "👉 Ejecuta: ${YELLOW}docker compose ps${NC} para ver el estado."
     echo -e "👉 Ejecuta: ${YELLOW}docker compose logs${NC} para ver errores."
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
    echo -e "  --db                    Entra a la consola MySQL"
    echo -e "  --clean-db              Resetea la base de datos (DROP/CREATE)"
    echo -e "  --update                Actualiza submódulos Git"
    echo -e "  --refresh-docker        Reconstruye imágenes desde cero"
    echo -e "  --logs-frontend         Muestra logs de servicio"
    echo -e "  --logs-backend          Muestra logs de servicio"
    echo -e "  --logs-live             Muestra todos los logs en vivo"
    echo -e "  --logs                  Muestra todos logs"
    echo -e "  --reset-frontend        Reincia servicio"
    echo -e "  --reset-backend         Reincia servicio"
    echo -e "  --bash-frontend         Entra al bash del contenedor frontend"
    echo -e "  --bash-backend          Entra al bash del contenedor backend"
    echo -e "  --hot-reload-backend    Fuerza hot-reload de backend"
    echo -e "  --hot-reload-frontend   Fuerza hot-reload de frontend"
    echo -e ""
    echo -e "🛑 ${RED}Peligro:${NC}"
    echo -e "  --kill            Detiene y elimina contenedores y volúmenes"
    echo -e "  --hard-reset      Borra TODO (imágenes, volúmenes, carpetas)"
    echo -e ""
}


check_services() {
    local services=("frontend" "backend" "db")
    for svc in "${services[@]}"; do
        if ! docker compose ps "$svc" --filter "status=running" | grep -q "Up"; then
            echo -e "${RED}❌ El servicio '$svc' no está corriendo.${NC}"
            return 1
        fi
    done
    return 0
}

print_state_msg(){
    if check_services; then
       MSG_Success
    else 
       MSG_Error
       exit 1
    fi
}


start(){
	if [[ "$DEV_MODE" == "1" ]]; then
		echo -e "${YELLOW}🚧 Iniciando en modo DESARROLLO...${NC}"
		docker compose -f "$FILE_DEV" up --build -d
	else
		echo -e "${GREEN}📦 Iniciando en modo PRODUCCIÓN...${NC}"
		docker compose -f "$FILE_PROD" up --build -d
	fi
}


confirm_action() {
    local mensaje="$1"
    local color="${2:-$GREEN}"

    echo -e "${color}$mensaje (s/n) [s]:${NC} "
    read -r respuesta

    respuesta=${respuesta:-s}

    case "$respuesta" in
        [Ss]|[Yy])
            return 0  # ← Continúa el script
            ;;
        [Nn])
            echo "Operación cancelada."
            exit 0   # ← Sale del script
            ;;
        *)
            echo "Respuesta no válida. Usa 's', 'n' o Enter para 'sí'."
            exit 1
            ;;
    esac
}

# --- LÓGICA DE ARGUMENTOS ---

case "$1" in
    --db)
        echo -e "${BLUE}📂 Accediendo a la base de datos  ${DB_NAMEs}...${NC}"
        docker exec -it -e MYSQL_PWD="$DB_PASSWORD" "$DB_CONTAINER" mysql -u root -p"$DB_PASSWORD" "$DB_NAME"
        exit 0
        ;;
    --bash-frontend)
       echo -e "${BLUE}📂 Accediendo al bash del contenedor...${NC}"
       docker exec -it ${FRONT_CONTAINER} /bin/bash
       exit 0
       ;;
    --bash-backend)
       echo -e "${BLUE}📂 Accediendo al bash del contenedor...${NC}"
       docker exec -it ${BACK_CONTAINER} /bin/bash
       exit 0
       ;;
    --hot-reload-backend)
        echo -e "${BLUE}📂 Refrescando backend...${NC}"
        docker exec -it ${BACK_CONTAINER} /bin/sh -c "mvn clean install -DskipTests" 
        exit 0
        ;;
    --hot-reload-frontend)
        echo -e "${BLUE}🔄 Reconstruyendo imagen frontend...${NC}"
        docker compose build frontend
        docker compose restart frontend
        exit 0
        ;;
    --clean-db)
        confirm_action "${MSG_KILL_DB} ¿Desea continuar?" "$YELLOW"
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
        confirm_action "${MSG_KILL_ALL} ¿Desea continuar?" "$YELLOW"
        pre_check
        echo -e "${RED}⚠️  Limpiando contenedores...${NC}"
        docker compose -f $FILE_DEV down -v --remove-orphans
        echo -e "${GREEN}✅ Limpieza completada.${NC}"
        exit 0
        ;;
    --update)
        echo -e "${BLUE}🔄 Actualizando submódulos...${NC}"
        git submodule update --init --recursive --remote
        exit 0
        ;;
    --logs-frontend|--logs-backend)
      SERVICE=${1#--logs-}
      docker compose -f $FILE_DEV logs $SERVICE
      exit 0
      ;;
    --logs)
      docker compose logs
      exit 0
      ;;
    --logs-live)
      docker compose logs -f
      exit 0
      ;;
    --reset-backend|--reset-frontend)
        SERVICE=${1#--reset-} 
        echo "♻️ Reiniciando $SERVICE..."
        docker compose -f $FILE_DEV restart $SERVICE
        exit 0
        ;;
    --help|-h)
        show_help
        exit 0
        ;;
    *)
        if [ -z "$1" ]; then
             confirm_action "¿Desea continuar y levantar la app?" "$GREEN"
             start
        else     
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
print_state_msg
