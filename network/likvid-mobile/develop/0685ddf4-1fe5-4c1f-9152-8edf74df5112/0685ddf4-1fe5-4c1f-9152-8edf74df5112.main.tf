#DELETED
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "0685ddf4-1fe5-4c1f-9152-8edf74df5112"
  location = "GermanyWestCentral"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/27"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }
