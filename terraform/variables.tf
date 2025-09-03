variable "project" {
  type    = string
  default = "ae-terraform-2025"
}

variable "location" {
  type    = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "mydatabase"
}

variable "database_user" {
  type    = string
  default = "dbuser"
}

variable "instance_connection_name" {
  type = string
  description = "Cloud SQL instance connection name in the format project:region:instance-name"
  default = "ae-terraform-2025:europe-west4:sarahs-db"
}