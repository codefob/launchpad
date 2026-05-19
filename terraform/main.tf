resource "azurerm_resource_group" "rg" {
  name     = "AKSLAB_2026"
  location = "centralus"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-529"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemo"

  default_node_pool {
    name       = "system-nodepool"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
     mode                  = "system"
  }

  
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "workernp"  
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  mode                  = "User"      

  orchestrator_version  = azurerm_kubernetes_cluster.aks.kubernetes_version
}


tags = {
    environment = "dev"
  }

  identity {
    type = "SystemAssigned"
  }
}