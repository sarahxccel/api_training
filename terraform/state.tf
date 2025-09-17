terraform {
  backend "gcs" {
    bucket  = "terraform-state-sarah"
    prefix  = "terraform/state"
  }
}