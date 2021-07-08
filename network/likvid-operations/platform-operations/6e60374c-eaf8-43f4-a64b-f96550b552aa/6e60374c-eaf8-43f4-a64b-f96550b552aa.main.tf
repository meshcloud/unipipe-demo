#DELETED
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "6e60374c-eaf8-43f4-a64b-f96550b552aa"
  location = "GermanyWestCentral"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/27"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }
