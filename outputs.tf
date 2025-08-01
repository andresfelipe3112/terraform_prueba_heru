output "cloud_run_url" {
  description = "URL del servicio de backend en Google Cloud Run."
  value       = google_cloud_run_service.backend.status[0].url
}

output "frontend_url" {
  description = "URL del bucket de Cloud Storage para el frontend estático."
  value       = "http://storage.googleapis.com/${google_storage_bucket.frontend_bucket.name}/index.html"
}
