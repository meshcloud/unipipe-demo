
class VnetHandler {
  name = "Vnet Handler";

  handle(service) {
    const params = service.instance.parameters;
    const context = service.instance.context;
    const bindings = service.bindings;
    const deleted = service.instance.deleted;

    return {
      // Hierarchy level 1
      name: "opendevstack",
      entries: [{
        // Hierarchy level 2: Folder "<customer id>"
        name: context.customer_id,
        entries: [
          {
            // Hierarchy level 3: Folder "<project id>"
            name: context.project_id,
                entries: [
                  { name: `${service.instance.serviceInstanceId}.instance.yml`, content:opendevstack(service) },
                ],
          },
        ],
      }],
    };
  }
}

function opendevstack(service) {
  return `${service.instance.deleted?"#DELETED":"---"}
customerId: ${service.instance.context.customer_id}
projectId: ${service.instance.context.project_id}
projectDescription: ${service.instance.parameters.desription}
`
}

const handlers = {
  "12B30C93-10B9-44DD-B334-0C6CC83E2C4A": new VnetHandler(),
};

handlers;
