#DELETED
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}

locals {
  address_space = "10.0.15.0/28"
}

resource "azurerm_resource_group" "main" {
  name     = "565e6dab-0e8a-451e-a71c-c0a9747f468e"
  location = "GermanyWestCentral"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "UP-565e6dab-0e8a-451e-a71c-c0a9747f468e"
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
  name                = "SG-565e6dab-0e8a-451e-a71c-c0a9747f468e"
  location            = "GermanyWestCentral"
  resource_group_name = azurerm_resource_group.main.name

  lifecycle {
    ignore_changes = [tags]
  }
}
