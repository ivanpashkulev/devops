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
    key                  = "azure/ivanpashkulev.com/runtime.tfstate"

    use_azuread_auth = true
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id

  features {}
}
