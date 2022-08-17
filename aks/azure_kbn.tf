# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

variable "app_image" {
  description = "Name of the image as it will appear in the repository"
}

variable "app_tag" {
  description = "tag to use for the app image"
}

resource "azurerm_container_registry" "test" {
  name                = "crispyreg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"

  # Build and push the container image
  provisioner "local-exec" {
    command = "az acr build --image ${var.app_image}:${var.app_tag} --registry ${self.name} --file ~/projects/crispy-clone/Dockerfile ."
  }

}

resource "azurerm_kubernetes_cluster" "test" {
  name                = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "crispy"

  default_node_pool {
    name               = "teststpool"
    vm_size            = "standard_b2s"
    node_count         = 1
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_role_assignment" "test" {
  principal_id                     = azurerm_kubernetes_cluster.test.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.test.id
  skip_service_principal_aad_check = true
}
