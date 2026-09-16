terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "vankatatfstatesa"
    container_name       = "tfstate"
    key                  = "azure/ivanpashkulev.com/production.tfstate"

    use_azuread_auth = true
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id

  resource_providers_to_register = [
    "Microsoft.AppConfiguration",
    "Microsoft.Compute",
    "Microsoft.GuestConfiguration",
    "Microsoft.HybridCompute",
    "Microsoft.HybridConnectivity",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
  ]

  features {
    app_configuration {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = true
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}
