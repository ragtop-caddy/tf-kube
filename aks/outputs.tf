data "azurerm_kubernetes_cluster" "test" {
    name = azurerm_kubernetes_cluster.test.name
    resource_group_name = azurerm_resource_group.test.name
}

output "location" {
  value       = azurerm_kubernetes_cluster.test.location
  description = "AKS Cluster Location"
}

output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.test.name
  description = "AKS Cluster Name"
}

output "image_pull_location" {
  value = "crispyreg.azurecr.io/${var.app_image}:${var.app_tag}"
}

output "kubernetes_cluster_host" {
  value        = data.azurerm_kubernetes_cluster.test.kube_config.0.host
  sensitive = true
}

output "client_certificate" {
  value     = base64decode(data.azurerm_kubernetes_cluster.test.kube_config.0.client_certificate)
  sensitive = true
}

output "client_key" {
  value = base64decode(data.azurerm_kubernetes_cluster.test.kube_config.0.client_key)
  sensitive = true
}

output "client_ca" {
  value = base64decode(data.azurerm_kubernetes_cluster.test.kube_config.0.cluster_ca_certificate)
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.test.kube_config_raw
  sensitive = true
}