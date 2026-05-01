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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

variable "environment" {
  default = "dr"
}

variable "dr_location" {
  default = "westus3"
}

locals {
  common_tags = {
    project     = "mwd-oil-azure-dr"
    environment = var.environment
    owner       = "security-ops"
    managed_by  = "terraform"
    region-role = "disaster-recovery"
  }
}

# DR resources default to count = 0
# Change count to 1 to enable during a declared DR event

resource "azurerm_resource_group" "dr_hub" {
  count    = 0
  name     = "rg-mwd-hub-\${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "dr_monitoring" {
  count    = 0
  name     = "rg-mwd-monitoring-\${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "dr_recovery" {
  count    = 0
  name     = "rg-mwd-recovery-\${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}
