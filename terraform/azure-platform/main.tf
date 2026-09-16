data "azurerm_client_config" "current" {}

locals {
  resource_name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name_prefix}-rg"
  location = var.azure_location
  tags     = local.common_tags
}

module "app_configuration" {
  source = "git::https://github.com/pashkulev-devops-projects/terraform-modules.git//azure/app-configuration?ref=v0.3.0"

  name                = "${local.resource_name_prefix}-app-config"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "free"

  role_assignments = {
    github_configuration_publisher = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "App Configuration Data Owner"
    }
    azure_admin_configuration_owner = {
      principal_id         = var.azure_admin_object_id
      role_definition_name = "App Configuration Data Owner"
    }
  }

  tags = local.common_tags
}

module "key_vault" {
  source = "git::https://github.com/pashkulev-devops-projects/terraform-modules.git//azure/key-vault?ref=v0.4.0"

  name                = "${local.resource_name_prefix}-kv"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku_name            = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  network_acls = {
    ip_rules = var.key_vault_allowed_ip_addresses
  }

  role_assignments = {
    github_secrets_publisher = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Key Vault Secrets Officer"
    }
    github_certificates_publisher = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Key Vault Certificates Officer"
    }
    azure_admin_secrets_reader = {
      principal_id         = var.azure_admin_object_id
      role_definition_name = "Key Vault Secrets User"
    }
    azure_admin_certificate_reader = {
      principal_id         = var.azure_admin_object_id
      role_definition_name = "Key Vault Certificate User"
    }
  }

  tags = local.common_tags
}
