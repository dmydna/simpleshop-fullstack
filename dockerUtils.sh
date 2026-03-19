#!/bin/bash


case "$1" in
    --all-containers)
        docker ps -a
        exit 0
        ;;
    --active-containers)
        docker ps
        exit 0
        ;;
    --run-backend|--run--frontend)
        SERVICE=${1#--run-} 
        echo "Correr servicio: $SERVICE."
        docker compose up --build -d $SERVICE
        exit 0
        ;;
    --stop-backend|--stop-frontend)
        SERVICE=${1#--stop-} 
        echo "Detener servicio: $SERVICE."
        docker compose down -v -d $SERVICE
        exit 0
        ;;
    --restart-backend|--restart-backend)
        SERVICE=${1#--restart-}
        echo "Reiniciar servicio $SERVICE."
        docker compose restart -d $SERVICE
        exit 0
        ;;
    --logs-frontend|--logs-backend)
        SERVICE=${1#--logs-}
        docker compose logs $SERVICE
        exit 0
        ;;
esac
