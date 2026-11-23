terraform {
  required_version = ">= 1.10.5"

  # OCI Object Storage S3-compatible bucket; parameters are injected by GitHub Actions.
  backend "s3" {}

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0, < 8.0.0"
    }
  }
}
