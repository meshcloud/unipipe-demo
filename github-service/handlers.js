
class Handler {
  name = "GitHub Service Handler";

  handle(service) {
    const params = service.instance.parameters;
    const context = service.instance.context;
    const bindings = service.bindings;
    const deleted = service.instance.deleted;

    var gcp_bindings = []
    bindings.forEach( (b) => {
      if (b.binding.bindResource.platform = "gcp.gcp-meshstack-dev") {
        gcp_bindings.push(gcp(b.binding.bindResource.tenant_id, params.repository))
      }
    });
    
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
                  { name: `${service.instance.serviceInstanceId}.main.tf`, content:tf(context.customer_id, context.project_id, params.repository, service.instance.serviceInstanceId, gcp_bindings, deleted) },
                ],
              }
            ],
          },
        ],
      }],
    };
  }
}

function tf (customerId, projectId, repositoryName, serviceInstanceId, gcpBindings, deleted) {
  return `${deleted?"#DELETED":""}
terraform {
  backend "gcs" {
    bucket = "unipipe-demo-pipeline-bucket"
    prefix = "github_services/${customerId}/${projectId}"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.15.0"
    }
    github = {
      source = "integrations/github"
      version = "4.22.0"
    }
  }
}

provider "github" {
  # Token is provided by GitHub action runner environment variable GITHUB_TOKEN
  owner = "meshcloud"
}

provider "google" {
}

resource "github_repository" "example" {
  name        = "${repositoryName}"
  description = "Infrastructure repository for project ${projectId} of customer ${customerId}."

  visibility = "private"

  template {
    owner      = "meshcloud"
    repository = "unipipe-demo-infrastructure-template"
  }
}
${gcpBindings.length > 0 ? gcpBindings.join("\n") : "" }`
}

function gcp(project_id, repositoryName) {
  return `
module "github_actions_sa" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id = "${project_id}"

  names        = ["githubactionssa"]
  display_name = "Github Actions SA"

  project_roles = ["${project_id}=>roles/owner"]
}

module "gh_oidc" {
  source         = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id     = "${project_id}"
  pool_id        = "github-identity-pool"
  provider_id    = "github-identity-provider"
  sa_mapping     = {
    "my_service_account" = {
      sa_name   = "projects/${project_id}/serviceAccounts/\${module.github_actions_sa.email}"
      attribute = "attribute.repository/meshcloud/${repositoryName}"
    }
  }
}

resource "github_actions_secret" "gcp_workload_identity_provider" {
  repository       = github_repository.example.name
  secret_name      = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value  = module.gh_oidc.provider_name
}

resource "github_actions_secret" "gcp_service_account" {
  repository       = github_repository.example.name
  secret_name      = "GCP_SERVICE_ACCOUNT"
  plaintext_value  = module.github_actions_sa.email
}`
}

const handlers = {
  "E1A838DE-AA9C-4DED-A23C-24824BC1B192": new Handler(),
};

handlers;
