#DELETED
terraform {
  backend "gcs" {
    bucket = "unipipe-demo-pipeline-bucket"
    prefix = "github_services/likvid-mobile/new-analytics-poc"
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
  app_auth {}
  owner = "likvid-bank"
}

provider "google" {
}

resource "github_repository" "example" {
  name        = "number-seven"
  description = "Infrastructure repository for project new-analytics-poc of customer likvid-mobile."

  visibility = "private"
}

module "github_actions_sa" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id = "likvid-mobile-new-analyt-u41"

  names        = ["githubactionssa"]
  display_name = "Github Actions SA"

  project_roles = ["likvid-mobile-new-analyt-u41=>roles/owner"]
}

module "gh_oidc" {
  source         = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id     = "likvid-mobile-new-analyt-u41"
  pool_id        = "github-identity-pool"
  provider_id    = "github-identity-provider"
  sa_mapping     = {
    "my_service_account" = {
      sa_name   = "projects/likvid-mobile-new-analyt-u41/serviceAccounts/${module.github_actions_sa.email}"
      attribute = "attribute.repository/likvid-bank/number-seven"
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