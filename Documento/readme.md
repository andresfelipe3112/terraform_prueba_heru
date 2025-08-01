Aquí tienes un **documento técnico estilo README** completo y mejorado que describe **cómo desplegar tu proyecto en Google Cloud Platform (GCP)**. Incluye todos los pasos necesarios, mejores prácticas y está preparado para ser usado como base en tu entrevista técnica con **Heru**.

---

# 🏗️ Documento Técnico: Despliegue Completo en GCP – Plataforma Heru

## 📌 Resumen General

Este documento describe detalladamente el proceso de despliegue para una arquitectura basada en microservicios en **Google Cloud Platform (GCP)**, incluyendo:

* Backend de Productos (NestJS)
* Backend de Autenticación (NestJS)
* Frontend (Next.js/React)
* Base de datos (PostgreSQL en Cloud SQL)
* CI/CD automatizado con **GitHub Actions**
* Infraestructura definida con **Terraform**

---

## 📊 Arquitectura General

```plaintext
    ┌────────────┐       ┌───────────────┐
    │  Frontend  │<──────┤  Google CDN   │
    └────┬───────┘       └───────────────┘
         │
         ▼
 ┌────────────────────┐
 │ GCS Static Website │
 └────────────────────┘

         ▼ (API calls)

 ┌────────────────────────────┐       ┌────────────────────────────┐
 │ Cloud Run - Product API    │<─────▶│ Cloud Run - Auth Service    │
 └────────────────────────────┘       └────────────────────────────┘
             │                                  │
             ▼                                  ▼
 ┌────────────────────┐             ┌────────────────────┐
 │ Cloud SQL (Postgre)│◀────────────┤    Common Database │
 └────────────────────┘             └────────────────────┘
```

---

## 🚀 Proceso de Despliegue (Paso a Paso)

### 🧱 Paso 1: Provisionamiento de Infraestructura con Terraform

1. Clona el repositorio con los archivos `main.tf`, `variables.tf`, `outputs.tf`.
2. Asegúrate de haber autenticado con GCP:

   ```bash
   gcloud auth application-default login
   ```
3. Ejecuta:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

Esto creará:

* Instancia de **Cloud SQL (PostgreSQL)**
* Servicios de **Cloud Run** para `product-backend` y `auth-backend`
* Bucket de **Google Cloud Storage** para el frontend
* Permisos públicos para acceder a los servicios y archivos

> El archivo `outputs.tf` te dará:
>
> * URLs de Cloud Run
> * URL del sitio frontend

---

### ⚙️ Paso 2: Configuración de Secretos en GitHub

En cada repositorio (`product`, `auth`, `frontend`):

* Ve a **Settings > Secrets and variables > Actions**
* Agrega:

| Nombre              | Valor                                   |
| ------------------- | --------------------------------------- |
| `GCP_SA_KEY`        | Contenido JSON de la cuenta de servicio |
| `DB_USER`           | Usuario de la base de datos             |
| `DB_PASSWORD`       | Contraseña de la base de datos          |
| `DB_HOST`           | IP pública de Cloud SQL                 |
| `DB_NAME`           | Nombre de la base de datos              |
| `JWT_SECRET` (auth) | Clave secreta para JWT                  |

---

### 🔄 Paso 3: Automatización CI/CD con GitHub Actions

#### 📦 Backend de Productos

Archivo: `.github/workflows/deploy-product.yml`

```yaml
name: Deploy Product Backend

on:
  push:
    branches: [main]

env:
  PROJECT_ID: your-gcp-project-id
  GCP_REGION: us-central1
  IMAGE_NAME: product-backend

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Auth GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: '${{ secrets.GCP_SA_KEY }}'

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2

    - name: Configure Docker
      run: gcloud auth configure-docker

    - name: Build & Push
      run: |
        docker build -t gcr.io/${{ env.PROJECT_ID }}/${{ env.IMAGE_NAME }} .
        docker push gcr.io/${{ env.PROJECT_ID }}/${{ env.IMAGE_NAME }}

    - name: Deploy to Cloud Run
      uses: google-github-actions/deploy-cloudrun@v2
      with:
        service: ${{ env.IMAGE_NAME }}
        region: ${{ env.GCP_REGION }}
        image: gcr.io/${{ env.PROJECT_ID }}/${{ env.IMAGE_NAME }}
        env_vars: |
          DATABASE_URL=postgres://${{ secrets.DB_USER }}:${{ secrets.DB_PASSWORD }}@${{ secrets.DB_HOST }}:5432/${{ secrets.DB_NAME }}
```

#### 🔐 Backend de Autenticación

Archivo: `.github/workflows/deploy-auth.yml` (similar al anterior)

Cambia el `IMAGE_NAME` a `auth-backend` y agrega:

```yaml
        env_vars: |
          JWT_SECRET=${{ secrets.JWT_SECRET }}
```

#### 🌐 Frontend

Archivo: `.github/workflows/deploy-frontend.yml`

```yaml
name: Deploy Frontend

on:
  push:
    branches: [main]

env:
  PROJECT_ID: your-gcp-project-id
  BUCKET_NAME: your-gcp-project-id-heru-frontend

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Auth GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: '${{ secrets.GCP_SA_KEY }}'

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2

    - name: Build static site
      run: |
        npm install
        npm run build
        npm run export

    - name: Deploy to GCS
      run: |
        gsutil -m rsync -r -c -d out gs://${{ env.BUCKET_NAME }}
```

---

## 🧪 Pruebas Locales

Usa Docker Compose para levantar el entorno de desarrollo local:

```bash
docker-compose up --build
```

### Estructura sugerida:

#### `docker-compose.yml`

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=heru
    env_file:
      - .env
    networks:
      - shared

  db:
    image: postgres:14
    restart: always
    environment:
      POSTGRES_DB: heru
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - shared

volumes:
  postgres_data:

networks:
  shared:
    name: shared
```

---

## 📈 Escalabilidad y Seguridad

### ✔️ Buenas prácticas aplicadas:

* Microservicios desacoplados (Cloud Run)
* CI/CD automatizado con GitHub Actions
* Autenticación JWT
* Secrets protegidos con GitHub Secrets
* Base de datos gestionada (Cloud SQL)
* Frontend en GCS con CDN

### 🚀 Futuras mejoras:

* ✅ Usar **Cloud Secret Manager** para variables sensibles
* 🔐 Migrar a redes privadas (VPC) para aislar servicios
* 📊 Activar **Cloud Monitoring + Logging** para métricas y alertas
* 🌍 Configurar **Custom Domain + HTTPS** para el frontend


---

## 🔐 Validación de Tokens entre Microservicios

En esta arquitectura, se implementa **validación de autenticación delegada**. Es decir:

### 🧩 ¿Cómo funciona?

1. **El frontend** incluye un JWT en cada request al backend de productos.

2. **El servicio `product-backend`** **no valida el token por sí mismo**, sino que **realiza una petición interna al microservicio `auth-backend`** para confirmar su validez.

3. El endpoint utilizado es:

   ```
   GET http://auth-nest:3002/auth/validate-token
   ```

   Con el header:

   ```http
   Authorization: Bearer <JWT_TOKEN>
   ```

4. Si `auth-backend` responde con `{ status: "valid" }`, entonces la petición continúa.

5. Si el token es inválido o no existe, se retorna `401 Unauthorized`.

### 🔄 Diagrama de flujo (Token Validation)

```plaintext
[Frontend]
     |
     | Authorization: Bearer eyJhbGciOi...
     ▼
[Product Backend] ──► [Auth Backend]
     |                     ▲
     |    /auth/validate-token
     ▼                     │
  Access ✅ or ❌      Token verification (JWT)
```

---

### 🛡️ Ventajas de este enfoque

✅ Permite centralizar la lógica de autenticación en un único microservicio
✅ Cada microservicio no necesita conocer el secreto JWT
✅ Escalable a múltiples servicios que consuman el validador
✅ Desacopla autenticación de la lógica de negocio


