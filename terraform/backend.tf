
terraform {
  backend "azurerm" {
    resource_group_name  = "cloud-shell"
    storage_account_name = "cs710032000b775b1d7"
    container_name       = "tfstate"
    key                  = "aks.tfstate"
    use_azuread_auth     = true
  }
}
