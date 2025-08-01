Gracias por el contexto. Lo estás haciendo muy bien. Aquí tienes una **sección mejorada y clara de “Despliegue paso a paso con CI/CD en GCP usando GitHub Actions”**. Puedes reemplazar directamente la sección `🚀 Proceso de Despliegue (Paso a Paso)` por esto en tu documento, para mejorar su claridad y profesionalismo.

---

## 🚀 Despliegue Paso a Paso con CI/CD en Google Cloud Platform (GCP)

Esta sección describe cómo desplegar automáticamente cada servicio (Auth, Productos y Frontend) en GCP usando **GitHub Actions** y **Terraform**.

---

### ✅ Paso 1: Crear y Configurar Proyecto en GCP

1. Crea un nuevo proyecto en Google Cloud Platform o usa uno existente.
2. Habilita los siguientes servicios:

   * Cloud Run
   * Cloud SQL Admin
   * Artifact Registry
   * IAM
   * Cloud Build
   * Cloud Storage
3. Crea una **cuenta de servicio** con los siguientes roles:

   * Cloud Run Admin
   * Cloud SQL Admin
   * Storage Admin
   * Artifact Registry Admin
   * Service Account User
4. Descarga el archivo JSON de la cuenta de servicio. Este se usará como `GCP_SA_KEY` en los repositorios de GitHub.

---

### ✅ Paso 2: Desplegar la Infraestructura con Terraform

1. Autentícate con tu cuenta de GCP:

   ```bash
   gcloud auth application-default login
   ```

2. Ejecuta Terraform:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Terraform creará:

   * Instancias de **Cloud Run**
   * **Cloud SQL** (PostgreSQL)
   * **Bucket GCS** para frontend
   * Variables de salida como URLs y credenciales

---

### ✅ Paso 3: Subir Variables Secretas a GitHub

En cada repositorio (`auth`, `product`, `frontend`):

1. Ve a `Settings > Secrets and variables > Actions > New repository secret`.
2. Agrega:

| Nombre              | Descripción                          |
| ------------------- | ------------------------------------ |
| `GCP_SA_KEY`        | JSON de la cuenta de servicio de GCP |
| `PROJECT_ID`        | ID del proyecto de GCP               |
| `DB_USER`           | Usuario de PostgreSQL                |
| `DB_PASSWORD`       | Contraseña de PostgreSQL             |
| `DB_HOST`           | IP pública de Cloud SQL              |
| `DB_NAME`           | Nombre de la base de datos           |
| `JWT_SECRET` (auth) | Clave secreta para firmar tokens     |

---

### ✅ Paso 4: Automatización con GitHub Actions

#### 📦 Backend – Productos (`.github/workflows/deploy-product.yml`)

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
    - name: Checkout
      uses: actions/checkout@v3

    - name: Authenticate with GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: '${{ secrets.GCP_SA_KEY }}'

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2
      with:
        project_id: ${{ env.PROJECT_ID }}

    - name: Configure Docker
      run: gcloud auth configure-docker

    - name: Build & Push Image
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

#### 🔐 Backend – Autenticación (`.github/workflows/deploy-auth.yml`)

Lo mismo que el anterior, pero con:

```yaml
  IMAGE_NAME: auth-backend
```

Y variables de entorno:

```yaml
        env_vars: |
          JWT_SECRET=${{ secrets.JWT_SECRET }}
          DATABASE_URL=postgres://${{ secrets.DB_USER }}:${{ secrets.DB_PASSWORD }}@${{ secrets.DB_HOST }}:5432/${{ secrets.DB_NAME }}
```

#### 🌐 Frontend – Next.js (`.github/workflows/deploy-frontend.yml`)

```yaml
name: Deploy Frontend

on:
  push:
    branches: [main]

env:
  PROJECT_ID: your-gcp-project-id
  BUCKET_NAME: heru-frontend-bucket

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Authenticate with GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: '${{ secrets.GCP_SA_KEY }}'

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2
      with:
        project_id: ${{ env.PROJECT_ID }}

    - name: Install & Build
      run: |
        npm install
        npm run build
        npm run export

    - name: Upload to GCS
      run: |
        gsutil -m rsync -r out gs://${{ env.BUCKET_NAME }}
```

> Asegúrate de que el bucket tenga habilitado el **hosting estático** y permisos públicos.

---

## ✅ Resultado Final

Después de este proceso:

* Cada push a `main` desplegará automáticamente los servicios a GCP.
* Tendrás URLs públicas para el frontend y los microservicios.
* Toda tu infraestructura estará versionada, automatizada y controlada por código.

---





DESPLIEGUE NEXTJS 

Perfecto, Andrés. Aquí tienes el **paso a paso para el despliegue automático (CI/CD) del frontend `Next.js` en Google Cloud (GCP)** usando **GitHub Actions** y **Google Cloud Run**, que es ideal para este caso por su facilidad y escalabilidad.

---

## ✅ Opción B: Despliegue automático del Frontend (Next.js) en GCP con GitHub Actions

### 🌐 Requisitos previos (hacer una sola vez):

1. **Tener una cuenta de Google Cloud** con un proyecto activo.
2. Habilitar:

   * Cloud Build
   * Artifact Registry
   * Cloud Run
3. Tener GitHub y tu repositorio con el frontend (`Next.js`) subido.
4. Instalar la CLI de Google Cloud (`gcloud`) localmente para configuración inicial.

---

### 🔐 1. Crear y configurar las credenciales de despliegue:

```bash
# Autenticarse con Google
gcloud auth login

# Seleccionar el proyecto
gcloud config set project TU_ID_PROYECTO

# Crear cuenta de servicio
gcloud iam service-accounts create github-actions-deploy \
  --display-name "GitHub Actions Deploy"

# Asignar permisos necesarios
gcloud projects add-iam-policy-binding TU_ID_PROYECTO \
  --member="serviceAccount:github-actions-deploy@TU_ID_PROYECTO.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding TU_ID_PROYECTO \
  --member="serviceAccount:github-actions-deploy@TU_ID_PROYECTO.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Crear key JSON
gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions-deploy@TU_ID_PROYECTO.iam.gserviceaccount.com
```

---

### 🔐 2. Subir credencial `key.json` a GitHub como secreto

* Ve a tu repositorio → **Settings** → **Secrets and variables** → **Actions** → `New repository secret`

  * Nombre: `GCP_CREDENTIALS`
  * Valor: (pega el contenido del `key.json`)

También puedes agregar:

* `GCP_PROJECT_ID`: tu ID de proyecto de GCP
* `GCP_REGION`: `us-central1` (o el que uses)

---

### ⚙️ 3. Crear archivo `.github/workflows/deploy.yml`

```yaml
name: Deploy to Google Cloud Run

on:
  push:
    branches:
      - main

jobs:
  deploy:
    name: Deploy Frontend to Cloud Run
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - name: Build Next.js app
        run: npm run build

      - name: Auth to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: '${{ secrets.GCP_CREDENTIALS }}'

      - name: Deploy to Cloud Run
        uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: nombre-del-servicio
          region: us-central1
          source: .
```

---

### 🎯 4. Configuración en GCP (una sola vez)

* Ve a Cloud Run > Crear servicio:

  * Nombre del servicio: `frontend`
  * Plataforma: Cloud Run
  * Código fuente: GitHub (opcional, o deja "Contenedor")
  * Región: `us-central1`
  * Configura acceso no autenticado: ✅
  * Usa la imagen construida por GitHub Actions

---

### ✅ Listo

Ahora, cada vez que hagas `git push origin main`, GitHub Actions:

* Instalará dependencias
* Compilará la app Next.js
* Subirá la app a Google Cloud Run

Y tendrás el frontend **totalmente desplegado** y accesible desde una URL pública como:

```
https://frontend-xxxxxx-uc.a.run.app
```

---
