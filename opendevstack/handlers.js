
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
  return `${service.instance.deleted?"#DELETED\n---":"---"}
apiVersion: v1
kind: meshProject
metadata:
  name: ${service.instance.context.project_id}-cd
  ownedByCustomer: ${service.instance.context.customer_id}
spec:
  displayName: ${service.instance.context.project_id}-cd
---
apiVersion: v1
kind: meshProject
metadata:
  name: ${service.instance.context.project_id}-dev
  ownedByCustomer: ${service.instance.context.customer_id}
spec:
  displayName: ${service.instance.context.project_id}-dev
---
apiVersion: v1
kind: meshProject
metadata:
  name: ${service.instance.context.project_id}-test
  ownedByCustomer: ${service.instance.context.customer_id}
spec:
  displayName: ${service.instance.context.project_id}-test
---
`
}

const handlers = {
  "12B30C93-10B9-44DD-B334-0C6CC83E2C4A": new VnetHandler(),
};

handlers;
