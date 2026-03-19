# Simple Shop Fullstack (Backend + Frontend + Docker) <br>

Es un ecommerce completo. Implementa una api restful con autentificacion mediante JWT (JSON Web Tokens), paginacion desde el servidor, manejo de bases de datos relacionales y persistencia real de usuarios y pedidos.

### Funcionalidades principales

__Backend (Spring Boot):__
- Autenticación JWT
- CRUD completo (productos, usuarios, listados)
- Subida y eliminación de imágenes
- Paginación en todas las entidades
- Base de datos PostgreSQL (o H2 en memoria)

__Frontend (React y Bootstrap):__
- Dashboard con wizard CRUD
- Login y registro funcionales
- Búsqueda con filtros
- Subida y eliminación de imágenes
- Diseño responsive


### Estructura del Proyecto

- **/frontend**: Aplicación cliente (Submódulo).
- **/backend**: API y lógica de negocio (Submódulo).
- **/.config**: Dockerfiles y Docker-Compose. 
- `docker-compose.yml`: Orquestación de contenedores.
- `start.sh`: Script de automatización para despliegue rápido.

---

### Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:
* [Docker Desktop](https://www.docker.com/products/docker-desktop)
* [Git](https://git-scm.com/)

---

### Instalación y Configuración

__1. Clonar el repositorio__
Como el proyecto utiliza submódulos, se debe clonar el repositorio padre e inicializar los hijos:

```bash
git clone --recursive https://github.com/dmydna/tp-simple-shop-docker.git
cd tu-repositorio-padre
git submodule update --init --recursive
```

__2. Uso del Script de Facilitación (start.sh)__
se incluye un script para automatizar la construcción y el levantamiento de los servicios.

Dar permisos de ejecución y ejcutar:
```bash
chmod +x start.sh
./start.sh
```

---

###  Uso de Docker

para ejecutar los comandos de Docker manualmente usa:

```bash
# 1. para Construir imagenes
docker compose build
# 2. para Levantar servicios
docker compose up 
```


> Los servicios estarán disponibles en:
> - **Frontend**: http://localhost:3000
> - **Backend API**: http://localhost:8080

---

### Notas Adicionales
Para __actualizar submódulos__ y traer las últimas versiones del frontend y backend:
```bash
git submodule update --remote --merge
```
---



