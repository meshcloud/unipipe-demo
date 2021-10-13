
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}

locals {
  address_space = "10.0.0.0/27"
}

resource "azurerm_resource_group" "main" {
  name     = "8beae56e-d9ed-4883-b38e-99a49d7099bc"
  location = "GermanyWestCentral"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "UP-8beae56e-d9ed-4883-b38e-99a49d7099bc"
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
  name                = "SG-8beae56e-d9ed-4883-b38e-99a49d7099bc"
  location            = "GermanyWestCentral"
  resource_group_name = azurerm_resource_group.main.name

  lifecycle {
    ignore_changes = [tags]
  }
}
