output "public_ip" {
  description = "IP pública de la VM del portafolio."
  value       = oci_core_instance.portfolio.public_ip
}

output "site_domain" {
  description = "Dominio configurado en Cloudflare."
  value       = cloudflare_dns_record.portfolio.name
}
