
terraform {
  backend "gcs" {
    bucket = "unipipe-demo-pipeline-bucket"
    prefix = "github_services/likvid-mobile/my-new-gcp-project"
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
  name        = "my-tstrepo"
  description = "Infrastructure repository for project my-new-gcp-project of customer likvid-mobile."

  visibility = "private"
}
