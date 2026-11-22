terraform {
  required_version = ">= 1.8.0"

  backend "remote" {
    workspaces { name = "portfolio-personal" }
  }

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0, < 8.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 5.0.0, < 6.0.0"
    }
  }
}
