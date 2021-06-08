
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
                  { name: `${service.instance.serviceInstanceId}.main.tf`, content: deleted?`#DESTROYED`:tf(params.vNetRegion, params.count_of_leading_1_bits_in_the_routing_mask) },
                ],
              }
            ],
          },
        ],
      }],
    };
  }
}

function tf (vNetRegion, count_of_leading_1_bits_in_the_routing_mask) {
  return `provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "infrastructure_rg" {
  name     = "infrastructure_rg"
  location = "West Europe"
}
// module "vnet" {
//   source              = "Azure/vnet/azurerm"
//   resource_group_name = azurerm_resource_group.infrastructure_rg.name
//   address_space       = ["10.0.0.0/${count_of_leading_1_bits_in_the_routing_mask}"]
//
//   depends_on = [azurerm_resource_group.infrastructure_rg]
// }`
}

const handlers = {
  "49f7d4f4-a00b-483a-9cc9-2519f9a7c6da": new VnetHandler(),
};

handlers;