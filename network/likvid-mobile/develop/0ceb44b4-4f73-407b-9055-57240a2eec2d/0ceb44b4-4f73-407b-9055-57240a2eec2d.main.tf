#DELETED
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "0ceb44b4-4f73-407b-9055-57240a2eec2d"
  location = "GermanyWestCentral"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/27"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }
