#DELETED
terraform {
  backend "gcs" {
    bucket = "unipipe-demo-pipeline-bucket"
    prefix = "github_services/likvid-mobile/develop"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.15.0"
    }
    github = {
      source  = "integrations/github"
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

resource "github_repository" "managed" {
  name        = "likvid-mobile-develop-undefined"
  description = "Infrastructure repository for project develop of customer likvid-mobile."

  gitignore_template = "Terraform"
  auto_init          = true

  visibility = "private"
  # We would like to use a template, but this is currently not supported for GitHub App Installations
  # See https://docs.github.com/en/rest/reference/repos#create-a-repository-using-a-template
  # Workaround: Create files main.tf and .github/workflow/pipeline.yml manually below
}

locals {
  commit_message = "Welcome Package by DevOps Toolchain Team"
  commit_author  = "DevOps Toolchain Team"
  commit_email   = "devopstoolchain@likvid-bank.com"
}

resource "github_repository_file" "maintf" {
  repository          = github_repository.managed.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = "main.tf"
  content             = <<-EOT
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.15.0"
    }
  }
}

provider "google" {
}
  EOT
}

resource "github_repository_file" "pipelineyml" {
  repository          = github_repository.managed.name
  commit_message      = local.commit_message
  commit_author       = local.commit_author
  commit_email        = local.commit_email

  file                = ".github/workflows/pipeline.yml"
  content             = <<-EOT
name: Deploy

on:
  push:
    branches:
      - "main"

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: write
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v1
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v0.4.0'
        with:
          workload_identity_provider: $${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: $${{ secrets.GCP_SERVICE_ACCOUNT }}
      - run: terraform init
      - run: terraform apply -auto-approve
      - name: git
        run: |
          git config --global user.email "team@example.com"
          git config --global user.name "Infrastructure Bot"
          git add .
          git diff-index --quiet HEAD || git commit -m "Update Infrastructure"
          git push
  EOT
}

module "github_actions_sa" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id = "likvid-mob-develop-mtihns7f"

  names        = ["githubactionssa"]
  display_name = "Github Actions SA"

  project_roles = ["likvid-mob-develop-mtihns7f=>roles/owner"]
}

module "gh_oidc" {
  source         = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id     = "likvid-mob-develop-mtihns7f"
  pool_id        = "github-identity-pool"
  provider_id    = "github-identity-provider"
  sa_mapping     = {
    "my_service_account" = {
      sa_name   = "projects/likvid-mob-develop-mtihns7f/serviceAccounts/${module.github_actions_sa.email}"
      attribute = "attribute.repository/likvid-bank/undefined"
    }
  }
}

resource "github_actions_secret" "gcp_workload_identity_provider" {
  repository       = github_repository.managed.name
  secret_name      = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value  = module.gh_oidc.provider_name
}

resource "github_actions_secret" "gcp_service_account" {
  repository       = github_repository.managed.name
  secret_name      = "GCP_SERVICE_ACCOUNT"
  plaintext_value  = module.github_actions_sa.email
}