
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}

locals {
  address_space = "10.1.2.0/28"
}

resource "azurerm_resource_group" "main" {
  name     = "7c3ed476-65c7-4aab-b060-66d59c51ea63"
  location = "GermanyWestCentral"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "UP-7c3ed476-65c7-4aab-b060-66d59c51ea63"
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

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "SG-7c3ed476-65c7-4aab-b060-66d59c51ea63"
  location            = "GermanyWestCentral"
  resource_group_name = azurerm_resource_group.main.name

  lifecycle {
    ignore_changes = [tags]
  }
}