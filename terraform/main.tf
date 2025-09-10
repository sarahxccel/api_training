# --- Provider ---
provider "google" {
  project = var.project
  region  = var.location
}

# # --- Enable necessary APIs ---
# resource "google_project_service" "artifact_registry" {
#   project = var.project
#   service = "artifactregistry.googleapis.com"
# }

# resource "google_project_service" "sql_admin" {
#   project = var.project
#   service = "sqladmin.googleapis.com"
# }

# resource "google_project_service" "run_api" {
#   project = var.project
#   service = "run.googleapis.com"
# }

# --- Project metadata ---
data "google_project" "project" {}

# --- Cloud SQL Instance ---
resource "google_sql_database_instance" "db_instance" {
  depends_on       = [google_project_service.sql_admin]
  name             = "sarahs-db"
  database_version = "POSTGRES_14"
  region           = var.location
  deletion_protection = var.deletion_protection

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "db" {
  name     = "mydatabase"
  instance = google_sql_database_instance.db_instance.name
}

resource "google_sql_user" "db_user" {
  name     = "dbuser"
  instance = google_sql_database_instance.db_instance.name
  password = var.db_password
}

# --- VPC Connector ---
resource "google_vpc_access_connector" "connector" {
  name          = "serverless-connector"
  region        = var.location
  network       = "default"
  ip_cidr_range = "10.8.0.0/28"

  min_throughput = 200
  max_throughput = 300
}

# --- IAM binding: allow Cloud Run to connect to Cloud SQL ---
resource "google_project_iam_member" "run_sql_access" {
  project = var.project
  role    = "roles/cloudsql.client"
  #member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  member = "serviceAccount:github-actions-sarah@ae-terraform-2025.iam.gserviceaccount.com"
}

# --- Cloud Run Service ---
resource "google_cloud_run_v2_service" "api" {
  depends_on          = [
    google_project_service.run_api,
    google_project_iam_member.run_sql_access
  ]
  name                = "sarahs-api"
  location            = var.location
  deletion_protection = var.deletion_protection

  template {
    service_account = "github-actions-sarah@ae-terraform-2025.iam.gserviceaccount.com"

    containers {
      image = "${var.location}-docker.pkg.dev/${var.project}/ae-2025-registry/sarahs-image:latest"

      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = var.instance_connection_name
      }

      env {
        name  = "DATABASE_NAME"
        value = var.database_name
      }

      env {
        name  = "DATABASE_USER"
        value = var.database_user
      }

      env {
        name  = "DATABASE_PASSWORD"
        value = var.db_password
      }

      # 👇 mount the Cloud SQL volume inside /cloudsql
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    # 👇 define the Cloud SQL volume
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.instance_connection_name]
      }
    }

    vpc_access {
      connector = google_vpc_access_connector.connector.id
    }
  }
}
