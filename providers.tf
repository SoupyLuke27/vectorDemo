# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  # backend "azurerm" {
  #       resource_group_name  = "tfstate"
  #       storage_account_name = "vectordemotfstate027"
  #       container_name       = "tfstate"
  #       key                  = "terraform.tfstate"
  #       access_key = ""
  # }
}
variable "prefix" {
  default = "vectordemo"
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # client_secret = ""
  # client_id = ""
  # subscription_id = ""
  # tenant_id = ""
}