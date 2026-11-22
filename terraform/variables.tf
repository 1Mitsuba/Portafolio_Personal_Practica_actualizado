variable "oci_tenancy_ocid" {
  type      = string
  sensitive = true
}
variable "oci_user_ocid" {
  type      = string
  sensitive = true
}
variable "oci_fingerprint" {
  type      = string
  sensitive = true
}
variable "oci_private_key" {
  type      = string
  sensitive = true
}
variable "oci_region" { type = string }
variable "oci_compartment_ocid" {
  type      = string
  sensitive = true
}
variable "oci_image_ocid" {
  type        = string
  description = "OCID Ubuntu 24.04 x86_64 de la región indicada."
}
variable "oci_ssh_public_key" {
  type      = string
  sensitive = true
}
variable "oci_admin_cidr" {
  type        = string
  description = "IP confiable para acceso SSH, por ejemplo 203.0.113.5/32."
}
variable "deployment_runner_cidr" {
  type        = string
  description = "CIDR temporal del runner GitHub que ejecuta Ansible."
}
variable "cloudflare_zone_id" {
  type      = string
  sensitive = true
}
variable "cloudflare_domain" {
  type        = string
  description = "Nombre completo DNS, por ejemplo portfolio.ejemplo.com."
}

variable "vcn_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}
variable "instance_shape" {
  type    = string
  default = "VM.Standard.E4.Flex"
}
variable "instance_ocpus" {
  type    = number
  default = 1
}
variable "instance_memory_gb" {
  type    = number
  default = 2
}
variable "boot_volume_gb" {
  type    = number
  default = 50
}
