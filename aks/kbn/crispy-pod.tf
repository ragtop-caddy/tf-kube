terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

data "terraform_remote_state" "aks" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

# Retrieve AKS cluster information
provider "azurerm" {
  project = data.terraform_remote_state.aks.outputs.project_id
  region  = data.terraform_remote_state.aks.outputs.region
  zone  = data.terraform_remote_state.aks.outputs.zone
}

provider "kubernetes" {
  host = data.terraform_remote_state.aks.outputs.kubernetes_cluster_host

  client_certificate     = data.terraform_remote_state.aks.outputs.client_certificate
  client_key             = data.terraform_remote_state.aks.outputs.client_key
  cluster_ca_certificate = data.terraform_remote_state.aks.outputs.client_ca
}

module "pod" {
  source = "../../kubernetes"
  app_source = data.terraform_remote_state.aks.outputs.image_pull_location
}
