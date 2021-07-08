provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "5d39f676-3c86-4e65-80f7-ed96902becbb"
  location = "GermanyWestCentral"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/26"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }