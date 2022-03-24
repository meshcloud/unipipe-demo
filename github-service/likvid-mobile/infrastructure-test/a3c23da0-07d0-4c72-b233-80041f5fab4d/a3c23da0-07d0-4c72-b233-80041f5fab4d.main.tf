
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