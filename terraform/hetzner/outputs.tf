output "server_ids" {
  value       = module.servers.server_ids
  description = "IDs of the Hetzner Cloud production servers."
}

output "ansible_target_public_ips" {
  value       = module.servers.public_ipv4_addresses
  description = "Public IPv4 addresses used by Ansible."
}

output "public_ipv6_addresses" {
  value       = module.servers.public_ipv6_addresses
  description = "Public IPv6 addresses assigned to the production servers."
}

output "dns_record_names" {
  value       = module.dns_records.record_names
  description = "Cloudflare DNS records pointing to the production servers."
}
