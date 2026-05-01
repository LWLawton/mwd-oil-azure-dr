# =============================================================================
# MWD Oil Co.
# Azure Hybrid DR Reference Architecture
# Disaster Recovery Environment
# West US 3
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

resource "azurerm_resource_group" "dr" {
  name     = "rg-mwd-dr-demo"
  location = "West US 3"

  tags = {
    project     = "mwd-oil-azure-dr"
    environment = "disaster-recovery"
    owner       = "security-ops"
  }
}
