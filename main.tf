provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

resource "google_cloud_run_service" "backend" {
  name     = "product-backend"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/product-backend" # img del containe aqui
        env {
          name  = "DATABASE_URL"
          value = "postgres://${var.db_user}:${var.db_password}@${google_sql_database_instance.postgres_instance.public_ip_address}:5432/${var.db_name}"
        }
      }
    }
  }

  traffics {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  service = google_cloud_run_service.backend.name
  location = google_cloud_run_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}


# ===== Recursos para el Frontend (React) =====

# Creamos un bucket de Cloud Storage para alojar los archivos estáticos del frontend
resource "google_storage_bucket" "frontend_bucket" {
  name = "${var.project_id}-heru-frontend"
  location = var.region
  uniform_bucket_level_access = true

  # Configuración para servir el bucket como un sitio web estático
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html" # Redirige errores 404 al index.html para React Router
  }
}

# Permite que todos los usuarios puedan ver el contenido del bucket (público)
resource "google_storage_bucket_iam_member" "frontend_access" {
  bucket = google_storage_bucket.frontend_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}


