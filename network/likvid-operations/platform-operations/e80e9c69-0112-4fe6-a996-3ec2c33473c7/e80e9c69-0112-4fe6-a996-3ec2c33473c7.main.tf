
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}

locals {
  address_space = "10.0.1.0/28"
}

resource "azurerm_resource_group" "main" {
  name     = "e80e9c69-0112-4fe6-a996-3ec2c33473c7"
  location = "GermanyWestCentral"
}

resource "azurerm_virtual_network" "main" {
  name                = "UP-e80e9c69-0112-4fe6-a996-3ec2c33473c7"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [ local.address_space ]

  subnet {
    name           = "public"
    address_prefix = cidrsubnet(local.address_space, 1, 0)
    security_group = azurerm_network_security_group.main.id
  }

  subnet {
    name           = "private"
    address_prefix = cidrsubnet(local.address_space, 1, 1)
    security_group = azurerm_network_security_group.main.id
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "SG-e80e9c69-0112-4fe6-a996-3ec2c33473c7"
  location            = "GermanyWestCentral"
  resource_group_name = azurerm_resource_group.main.name
}
