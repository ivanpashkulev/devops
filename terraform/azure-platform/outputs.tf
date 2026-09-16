output "resource_group_name" {
  description = "Name of the Azure platform resource group"
  value       = azurerm_resource_group.this.name
}

output "app_configuration_name" {
  description = "Name of the App Configuration store"
  value       = module.app_configuration.name
}

output "app_configuration_endpoint" {
  description = "Endpoint of the App Configuration store"
  value       = module.app_configuration.endpoint
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}

output "github_oidc_principal_id" {
  description = "Object ID of the GitHub OIDC principal used by Terraform"
  value       = data.azurerm_client_config.current.object_id
}
