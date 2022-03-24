
terraform {
  backend "local" {
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
  name        = "number-five"
  description = "Infrastructure repository for project platform-operations of customer likvid-operations."

  visibility = "private"

  template {
    owner      = "meshcloud"
    repository = "unipipe-demo-infrastructure-template"
  }
}