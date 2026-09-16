variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_location" {
  type        = string
  description = "Azure region"
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
