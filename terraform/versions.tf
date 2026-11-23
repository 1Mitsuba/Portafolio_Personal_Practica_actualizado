terraform {
  required_version = ">= 1.12.0"

  # OCI Object Storage bucket with versioning; parameters are injected by GitHub Actions.
  backend "oci" {}

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}
