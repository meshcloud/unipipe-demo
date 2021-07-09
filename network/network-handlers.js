
class VnetHandler {
  name = "Vnet Handler";

  handle(service) {
    const params = service.instance.parameters;
    const context = service.instance.context;
    const bindings = service.bindings;
    const deleted = service.instance.deleted;

    return {
      // Hierarchy level 1
      name: "network",
      entries: [{
        // Hierarchy level 2: Folder "<customer id>"
        name: context.customer_id,
        entries: [
          {
            // Hierarchy level 3: Folder "<project id>"
            name: context.project_id,
            entries: [
              {
                // Hierarchy level 4: Folder "<instance id>"
                // this prevents collisions for multiple instances under the same meshProject
                name: service.instance.serviceInstanceId,
                entries: [
                  { name: `${service.instance.serviceInstanceId}.main.tf`, content:tf(params.VNetRegion, params.VNetIP, params.CidrBlock, service.instance.serviceInstanceId, deleted) },
                ],
              }
            ],
          },
        ],
      }],
    };
  }
}

function tf (VNetRegion, VNetIP, CidrBlock, serviceInstanceId, deleted) {
  return `${deleted?"#DELETED":""}
terraform {
  backend "local" {
  }
}
provider "azurerm" {
  features {}
}

locals {
  address_space = "${VNetIP}/${CidrBlock}"
}

resource "azurerm_resource_group" "main" {
  name     = "${serviceInstanceId}"
  location = "${VNetRegion}"
}

resource "azurerm_virtual_network" "main" {
  name                = "UP-${serviceInstanceId}"
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
  name                = "SG-${serviceInstanceId}"
  location            = "${VNetRegion}"
  resource_group_name = azurerm_resource_group.main.name
}
`
}

const handlers = {
  "49f7d4f4-a00b-483a-9cc9-2519f9a7c6da": new VnetHandler(),
};

handlers;