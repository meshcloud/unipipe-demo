
terraform {
  backend "gcs" {
    bucket = "unipipe-demo-pipeline-bucket"
    prefix = "github_services/likvid-mobile/infrastructure-test"
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
  name        = "infrastructure-test"
  description = "Infrastructure repository for project infrastructure-test of customer likvid-mobile."

  visibility = "private"

  template {
    owner      = "meshcloud"
    repository = "unipipe-demo-infrastructure-template"
  }
}

module "github_actions_sa" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id = "likvid-mobile-infrastruc-l76"

  names        = ["githubactionssa"]
  display_name = "Github Actions SA"

  project_roles = ["likvid-mobile-infrastruc-l76=>roles/owner"]
}

module "gh_oidc" {
  source         = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id     = "likvid-mobile-infrastruc-l76"
  pool_id        = "github-identity-pool"
  provider_id    = "github-identity-provider"
  sa_mapping     = {
    "my_service_account" = {
      sa_name   = "projects/likvid-mobile-infrastruc-l76/serviceAccounts/${module.github_actions_sa.email}"
      attribute = "attribute.repository/meshcloud/infrastructure-test"
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
}