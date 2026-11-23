output "public_ip" {
  description = "IP pública de la VM del portafolio."
  value       = oci_core_instance.portfolio.public_ip
}
