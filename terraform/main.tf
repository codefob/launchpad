#---Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "lab2026"
  location = "centralus"
}

#---AKS Cluster
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

  #--network_plugin
  network_profile {
    network_plugin      = "azure"
    load_balancer_sku   = "standard"
  }

  tags = {
    environment = "dev"
  }
}

#---user nodepool creation 
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "usernp01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size    = "Standard_DS2_v2"
  node_count = 1

  mode = "User" 

  orchestrator_version = azurerm_kubernetes_cluster.aks.kubernetes_version

  tags = {
    environment = "dev"
  }
}