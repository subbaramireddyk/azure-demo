terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-demo"
    storage_account_name = "sttfstatedemo31592" // Replace with actual name from script
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
