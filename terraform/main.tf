locals {
  ssh_cidrs = distinct([var.oci_admin_cidr, var.deployment_runner_cidr])
  public_ingress = [
    { source = "0.0.0.0/0", port = 80 },
    { source = "0.0.0.0/0", port = 443 },
  ]
  ssh_ingress = [for cidr in local.ssh_cidrs : { source = cidr, port = 22 }]
}

data "oci_identity_availability_domains" "available" {
  compartment_id = var.oci_compartment_ocid
}

resource "oci_core_vcn" "portfolio" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "portfolio-vcn"
  cidr_block     = var.vcn_cidr
  dns_label      = "portfolio"
}

resource "oci_core_internet_gateway" "portfolio" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.portfolio.id
  display_name   = "portfolio-internet-gateway"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.portfolio.id
  display_name   = "portfolio-public-routes"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.portfolio.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.portfolio.id
  display_name   = "portfolio-public-ingress"

  dynamic "ingress_security_rules" {
    for_each = concat(local.public_ingress, local.ssh_ingress)
    content {
      protocol    = "6"
      source      = ingress_security_rules.value.source
      source_type = "CIDR_BLOCK"
      tcp_options {
        min = ingress_security_rules.value.port
        max = ingress_security_rules.value.port
      }
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.oci_compartment_ocid
  vcn_id                     = oci_core_vcn.portfolio.id
  display_name               = "portfolio-public-subnet"
  cidr_block                 = var.public_subnet_cidr
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = "web"
}

resource "oci_core_instance" "portfolio" {
  compartment_id      = var.oci_compartment_ocid
  availability_domain = data.oci_identity_availability_domains.available.availability_domains[0].name
  display_name        = "portfolio-personal"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = var.oci_image_ocid
    boot_volume_size_in_gbs = var.boot_volume_gb
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    display_name     = "portfolio-vnic"
    hostname_label   = "portfolio"
  }

  metadata = { ssh_authorized_keys = var.oci_ssh_public_key }
}

resource "cloudflare_dns_record" "portfolio" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_domain
  type    = "A"
  content = oci_core_instance.portfolio.public_ip
  ttl     = 1
  proxied = true
  comment = "Managed by GitHub Actions and Terraform"
}
