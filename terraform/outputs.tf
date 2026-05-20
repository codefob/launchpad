output "aks_name" {
  value = var.create_aks ? azurerm_kubernetes_cluster.aks[0].name : data.azurerm_kubernetes_cluster.existing_aks[0].name
}
