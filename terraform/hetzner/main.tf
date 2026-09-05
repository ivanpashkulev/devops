data "http" "runner_public_ip" {
  url = "https://api.ipify.org"
}

data "cloudflare_ip_ranges" "this" {}

locals {
  common_labels = {
    project     = "ivanpashkulev-com"
    environment = "production"
    managed_by  = "terraform"
  }
}

module "ssh_key" {
  source = "git::https://github.com/pashkulev-devops-projects/terraform-modules.git//hetzner/ssh-key?ref=v0.2.0"

  name       = "ansible-server-key"
  public_key = var.ansible_server_public_ssh_key
  labels     = local.common_labels
}

module "firewall" {
  source = "git::https://github.com/pashkulev-devops-projects/terraform-modules.git//hetzner/firewall?ref=v0.2.0"

  name = "ivanpashkulev-production-firewall"

  rules = [
    {
      direction = "in"
      protocol  = "tcp"
      port      = "22"
      source_ips = concat(
        tolist(var.allowed_ssh_ips),
        ["${chomp(data.http.runner_public_ip.response_body)}/32"]
      )
      description = "Allow SSH from trusted addresses and the deployment runner"
    },
    {
      direction   = "in"
      protocol    = "tcp"
      port        = "80"
      source_ips  = data.cloudflare_ip_ranges.this.ipv4_cidrs
      description = "Allow HTTP traffic from Cloudflare IP ranges"
    },
    {
      direction   = "in"
      protocol    = "tcp"
      port        = "443"
      source_ips  = data.cloudflare_ip_ranges.this.ipv4_cidrs
      description = "Allow HTTPS traffic from Cloudflare IP ranges"
    }
  ]

  labels = local.common_labels
}

module "servers" {
  source = "git::https://github.com/pashkulev-devops-projects/terraform-modules.git//hetzner/server?ref=v0.2.0"

  server_count     = var.server_count
  server_base_name = var.server_base_name
  server_type      = var.server_type
  location         = var.location
  image            = var.image

  ssh_keys     = [tostring(module.ssh_key.id)]
  firewall_ids = [module.firewall.firewall_id]
  labels       = local.common_labels
}

locals {
  cloudflare_records = merge([
    for index, ipv4 in module.servers.public_ipv4_addresses : {
      "main-${index + 1}" = {
        name    = "ivanpashkulev.com"
        type    = "A"
        content = ipv4
        ttl     = 1
        proxied = true
        comment = "Hetzner production server ${index + 1}"
      }

      "dj-${index + 1}" = {
        name    = "dj.ivanpashkulev.com"
        type    = "A"
        content = ipv4
        ttl     = 1
        proxied = true
        comment = "Hetzner production server ${index + 1}"
      }
    }
  ]...)
}

module "dns_records" {
  source = "git::https://github.com/pashkulev-devops-projects/terraform-modules.git//cloudflare/dns-records?ref=v0.2.0"

  zone_id = var.cloudflare_zone_id
  records = local.cloudflare_records
}
