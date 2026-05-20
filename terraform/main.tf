# ✅ Resource Group (AKS)
resource "azurerm_resource_group" "rg" {
  name     = "lab2026"
  location = "centralus"
}

#  Existing ACR (UPDATED RG)
data "azurerm_container_registry" "acr" {
  name                = "codefob"
  resource_group_name = "acr-2025"   
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-github-actions"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksgithub"

  default_node_pool {
    name       = "sysnp"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
     }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "usernp01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size    = "Standard_DS2_v2"
  node_count = 1
  mode       = "User"

  orchestrator_version = azurerm_kubernetes_cluster.aks.kubernetes_version
}
# --- AKS integration with ACR registry
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
}
