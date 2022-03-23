#DELETED
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
  owner = "meshcloud"
}

resource "github_repository" "example" {
  name        = "my-first-repo"
  description = "Infrastructure repository for project platform-operations of customer likvid-operations."

  visibility = "private"

  template {
    owner      = "meshcloud"
    repository = "unipipe-demo-infrastructure-template"
  }
}
