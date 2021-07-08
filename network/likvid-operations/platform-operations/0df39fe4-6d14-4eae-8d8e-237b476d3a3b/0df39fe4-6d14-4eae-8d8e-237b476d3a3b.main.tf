provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "0df39fe4-6d14-4eae-8d8e-237b476d3a3b"
  location = "GermanyWestCentral"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/27"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }