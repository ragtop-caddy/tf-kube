variable "name" {
  description = "Name of the Azure Kubernetes Cluster"
}

variable "location" {
    description = "Azure Region where the kubernetes cluster will be located"
}

resource "azurerm_resource_group" "test" {
  name     = var.name
  location = var.location
}