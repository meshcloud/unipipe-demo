provider "azurerm" {
  features {}
  tenant = "5f0e994b-6436-4f58-be96-4dc7bebff827" // Meshcloud GmbH AAD tenant
  subscription = "undefined"
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "infrastructure_rg"
  location = "West Europe"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/27"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }