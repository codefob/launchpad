variable "create_aks" {
  type    = bool
  default = false
}

# AKS resource group
resource "azurerm_resource_group" "rg" {
  name     = "lab2026"
  location = "centralus"
}

# Existing ACR
data "azurerm_container_registry" "acr" {
  name                = "codefob"
  resource_group_name = "acr-2025"
}

# Existing AKS (used only when create_aks = false)
data "azurerm_kubernetes_cluster" "existing_aks" {
  count               = var.create_aks ? 0 : 1
  name                = "aks-github-actions"
  resource_group_name = "lab2026"
}

# New AKS (used only when create_aks = true)
resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.create_aks ? 1 : 0
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

# Locals to unify references whether AKS is new or existing

locals {
  aks_id = var.create_aks ? azurerm_kubernetes_cluster.aks[0].id : data.azurerm_kubernetes_cluster.existing_aks[0].id

  kubelet_object_id = var.create_aks ? azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id : data.azurerm_kubernetes_cluster.existing_aks[0].kubelet_identity[0].object_id
}


# User node pool — create only when creating the AKS cluster in Terraform
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  count                 = var.create_aks ? 1 : 0
  name                  = "usernp01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id

  vm_size    = "Standard_DS2_v2"
  node_count = 1
  mode       = "User"

  orchestrator_version = azurerm_kubernetes_cluster.aks[0].kubernetes_version
}

# ---- AKS integration with ACR 
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = local.kubelet_object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
}