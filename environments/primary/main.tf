# =============================================================================
# MWD Oil Co.
# Azure Hybrid DR Reference Architecture
# Primary Environment
# South Central US
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary" {
  name     = "rg-mwd-primary-demo"
  location = "South Central US"

  tags = {
    project     = "mwd-oil-azure-dr"
    environment = "primary"
    owner       = "security-ops"
  }
}
