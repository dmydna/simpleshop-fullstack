# Simple Shop Fullstack (Backend + Frontend + Docker) <br>

<<<<<<< HEAD
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

=======
Proyecto e-commerce fullstack con una UI responsiva construida con React + Bootstrap y una API RESTfull construida con Spring Boot + JWT.
>>>>>>> fab3349 (update README.md)

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

__1. Clonar el repositorio e inicializarlo__. <br>
Como el proyecto utiliza submódulos, se debe clonar el repositorio padre e inicializar los hijos:

```bash
git clone --recursive https://github.com/dmydna/simpleshop-fullstack.git
cd simpleshop-fullstack
git submodule update --init --recursive
```


> Nota: para __actualizar submódulos__ <br>
>  y traer las últimas versiones del frontend y backend usar: <br>
> `git submodule update --remote --merge`

__2. Uso del Script de start.sh__.<br>
Se incluye un script para automatizar la construcción y el levantamiento de los servicios.

Dar permisos de ejecución:
```bash
chmod +x start.sh
```
Modo de uso:
1. `start.sh`: para correr y levantar proyecto. 
2. `start.sh --help`: para ver todos los comandos.

__3. Uso de Env.__<br>
Se incluye un env con variables de entorno para automatizar la configuraciones.

Principales variables:
1. `COMPOSE_FILE`: indica el docker file en `.config`
2. `DB_NAME, DB_PASSWORD, DB_ROOT_USER`: nombre, password y usuario de bases de datos.
3. `APP_ADMIN_USERNAME, APP_ADMIN_PASSWORD`: usuario y password de admin
 
---

###  Uso de Docker
Para ejecutar los comandos de Docker manualmente usar:

```bash

cd simpleshop-fullstack
# para levantar e incializar el proyecto (recompila proyecto)
docker compose up --build
# para levantar el proyecto
docker compose up 
```


> Los __servicios__ estarán disponibles en:
> - **Frontend**: `http://localhost:3000`
> - **Backend API**: `http://localhost:8080`

---




<<<<<<< HEAD
=======
__Backend (Spring Boot):__
- Autenticación JWT
- CRUD completo (productos, usuarios, listados)
- Subida y eliminación de imágenes
- Paginación en todas las entidades
- Base de datos MySQL (o H2 en memoria)

__Frontend (React y Bootstrap):__
- Dashboard con wizard CRUD
- Login y registro funcionales
- Búsqueda con filtros avanzados
- Subida y eliminación de imágenes
- Diseño responsive
>>>>>>> fab3349 (update README.md)

