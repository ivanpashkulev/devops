locals {
  resource_name_prefix = "${var.project_name}-${var.environment}"
}

data "azurerm_arc_machine" "this" {
  name                = "${local.resource_name_prefix}-server"
  resource_group_name = "${local.resource_name_prefix}-rg"
}

data "azurerm_app_configuration" "this" {
  name                = "${local.resource_name_prefix}-app-config"
  resource_group_name = "${local.resource_name_prefix}-rg"
}

data "azurerm_key_vault" "this" {
  name                = "${local.resource_name_prefix}-kv"
  resource_group_name = "${local.resource_name_prefix}-rg"
}

resource "azurerm_role_assignment" "arc_machine_app_configuration_reader" {
  scope                = data.azurerm_app_configuration.this.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = data.azurerm_arc_machine.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "arc_machine_key_vault_secrets_reader" {
  scope                = data.azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_arc_machine.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "arc_machine_key_vault_certificate_reader" {
  scope                = data.azurerm_key_vault.this.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = data.azurerm_arc_machine.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}
