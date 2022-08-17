terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }
}

variable "app_image" {
  default = ""
  description = "String identifying pull location for application image"
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

# Retrieve GKE cluster information
provider "google" {
  project = data.terraform_remote_state.gke.outputs.project_id
  region  = data.terraform_remote_state.gke.outputs.region
  zone  = data.terraform_remote_state.gke.outputs.zone
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name             = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location         = data.terraform_remote_state.gke.outputs.zone
}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.gke.outputs.kubernetes_cluster_host}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

module "pod" {
  source = "../kubernetes"
  app_source = var.app_image
}