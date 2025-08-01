variable "project_id" {}
variable "region" {
  default = "us-central1"
}
variable "db_password" {}
variable "db_user" {
  default = "postgres"
}
variable "db_name" {
  default = "product_db"
}
