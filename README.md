# Simple Shop 

Esta es una aplicación **fullstack** que utiliza una arquitectura de microservicios o repositorios separados mediante **Git Submodules**.

## Estructura del Proyecto

- **/frontend**: Aplicación cliente (Submódulo).
- **/backend**: API y lógica de negocio (Submódulo).
- **/.config**: Dockerfiles y Docker-Compose. 
- `docker-compose.yml`: Orquestación de contenedores.
- `setup.sh`: Script de automatización para despliegue rápido.

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:
* [Docker Desktop](https://www.docker.com/products/docker-desktop)
* [Git](https://git-scm.com/)

---

## Instalación y Configuración

### 1. Clonar el repositorio
Como el proyecto utiliza submódulos, debes clonar el repositorio padre e inicializar los hijos:

```bash

git clone --recursive https://github.com/dmydna/tp-simple-shop-docker.git
cd tu-repositorio-padre

```


Si ya clonaste el proyecto sin el comando --recursive, ejecuta:

```bash
git submodule update --init --recursive
```


2. Uso del Script de Facilitación (setup.sh)
Hemos incluido un script para automatizar la construcción y el levantamiento de los servicios.

Dar permisos de ejecución:

```bash
chmod +x setup.sh
```

##### Ejecutar el proyecto:

```bash
./setup.sh
```

---

##  Docker Compose

Si prefieres ejecutar los comandos de Docker manualmente:

##### Construir las imágenes:

```bash
docker-compose build
```
##### Levantar los servicios:

```bash
docker-compose up -d
```
Los servicios estarán disponibles en:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080

---

### Notas Adicionales
#### Actualizar Submódulos

Para traer las últimas versiones del frontend y backend:

```bash
git submodule update --remote --merge
``
