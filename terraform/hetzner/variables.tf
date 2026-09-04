variable "server_count" {
  type        = number
  description = "Number of Hetzner Cloud servers to create."
  default     = 1
}

variable "server_base_name" {
  type        = string
  description = "Base name of the Hetzner Cloud servers."
  default     = "ivanpashkulev-production"
}

variable "server_type" {
  type        = string
  description = "Hetzner Cloud server type."
  default     = "cx23"
}

variable "location" {
  type        = string
  description = "Hetzner Cloud location."
  default     = "nbg1"
}

variable "image" {
  type        = string
  description = "Operating-system image used by the servers."
  default     = "ubuntu-24.04"
}

variable "allowed_ssh_ips" {
  type        = set(string)
  description = "CIDR ranges allowed to connect over SSH."

  validation {
    condition     = length(var.allowed_ssh_ips) > 0
    error_message = "allowed_ssh_ips must contain at least one CIDR range."
  }
}

variable "ansible_server_public_ssh_key" {
  type        = string
  description = "Public SSH key used by Ansible."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID for ivanpashkulev.com."
}
