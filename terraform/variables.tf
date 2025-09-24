variable "project" {
  type    = string
  sensitive = true
}

variable "location" {
  type    = string
  sensitive = true
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
  sensitive = true
}

variable "database_user" {
  type    = string
  sensitive = true
}

variable "instance_connection_name" {
  type = string
  sensitive = true
  description = "Cloud SQL instance connection name in the format project:region:instance-name"
}

variable "docker_registry" {
  type        = string
  description = "Name of the Docker Artifact Registry repo"
}