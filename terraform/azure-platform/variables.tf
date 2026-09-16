variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_location" {
  type        = string
  description = "Azure region"
}

variable "azure_admin_object_id" {
  type        = string
  description = "Microsoft Entra object ID of the Azure administrator"
}

variable "key_vault_allowed_ip_addresses" {
  type        = set(string)
  description = "IP addresses allowed to access the Key Vault"
}

variable "project_name" {
  type        = string
  description = "Project name used in Azure resource names"
  default     = "ivanpashkulev"
}

variable "environment" {
  type        = string
  description = "Deployment environment used in Azure resource names"
  default     = "prod"
}
