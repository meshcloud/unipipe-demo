
class Handler {
  name = "GitHub Service Handler";

  handle(service) {
    const params = service.instance.parameters;
    const context = service.instance.context;
    const bindings = service.bindings;
    const deleted = service.instance.deleted;

    return {
      // Hierarchy level 1
      name: "github-service",
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
                  { name: `${service.instance.serviceInstanceId}.main.tf`, content:tf(context.customer_id, context.project_id, params.repository, service.instance.serviceInstanceId, deleted) },
                ],
              }
            ],
          },
        ],
      }],
    };
  }
}

function tf (customerId, projectId, repositoryName, serviceInstanceId, deleted) {
  return `${deleted?"#DELETED":""}
terraform {
  backend "local" {
  }

  required_providers {
    github = {
      source = "integrations/github"
      version = "4.22.0"
    }
  }
}

provider "github" {
  # Token is provided by GitHub action runner environment variable GITHUB_TOKEN
}



resource "github_repository" "example" {
  name        = "${repositoryName}"
  description = "Infrastructure repository for project ${projectId} of customer ${customerId}."

  visibility = "private"

  # template {
  #   owner      = "meshcloud"
  #   repository = "unipipe-demo-infrastructure-template"
  # }
}
`
}

const handlers = {
  "E1A838DE-AA9C-4DED-A23C-24824BC1B192": new Handler(),
};

handlers;