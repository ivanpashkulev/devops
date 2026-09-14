output "server_ids" {
  value       = module.servers.server_ids
  description = "IDs of the Hetzner Cloud production servers."
}

output "ansible_target_public_ips" {
  value       = module.servers.public_ipv4_addresses
  description = "Public IPv4 addresses used by Ansible."
}

output "wireguard_server_endpoint" {
  value       = one(module.servers.public_ipv4_addresses)
  description = "Public IPv4 endpoint of the WireGuard server."
}

output "public_ipv6_addresses" {
  value       = module.servers.public_ipv6_addresses
  description = "Public IPv6 addresses assigned to the production servers."
}

output "dns_record_names" {
  value       = module.dns_records.record_names
  description = "Cloudflare DNS records pointing to the production servers."
}

output "turnstile_site_key" {
  value       = cloudflare_turnstile_widget.chat.sitekey
  description = "Public site key used to render the Turnstile widget."
}

output "turnstile_secret_key" {
  value       = cloudflare_turnstile_widget.chat.secret
  description = "Secret key used by the API to validate Turnstile tokens."
  sensitive   = true
}
