provider "azurerm" {
  features {}
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