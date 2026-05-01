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

# =============================================================================
# DR RESOURCE GROUPS (conditionally created with count)
# =============================================================================

resource "azurerm_resource_group" "dr_hub" {
  count    = var.dr_resource_count
  name     = "rg-mwd-dr-hub"
  location = var.dr_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "dr_monitoring" {
  count    = var.dr_resource_count
  name     = "rg-mwd-dr-monitoring"
  location = var.dr_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "dr_recovery" {
  count    = var.dr_resource_count
  name     = "rg-mwd-dr-recovery"
  location = var.dr_location

  tags = local.common_tags
}

# =============================================================================
# DR NETWORK MODULES (conditionally created with count = 0 by default)
# Set count = 1 in terraform.tfvars to enable DR resources
# =============================================================================

module "dr_hub_network" {
  count              = var.dr_resource_count
  source             = "../../modules/network-hub"
  resource_group_name = azurerm_resource_group.dr_hub[0].name
  location            = var.dr_location
  environment         = var.environment
  hub_vnet_name       = "vnet-mwd-dr-hub"
  hub_address_space   = var.dr_hub_address_space
  gateway_subnet_cidr = var.dr_gateway_subnet_cidr
  mgmt_subnet_cidr    = var.dr_mgmt_subnet_cidr
  shared_subnet_cidr  = var.dr_shared_subnet_cidr
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

# =============================================================================
# DR MONITORING MODULE (conditionally created with count = 0 by default)
# =============================================================================

module "dr_monitoring" {
  count              = var.dr_resource_count
  source             = "../../modules/monitoring"
  resource_group_name = azurerm_resource_group.dr_monitoring[0].name
  location            = var.dr_location
  environment         = var.environment
  workspace_name      = "law-mwd-dr"
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags
}

# =============================================================================
# DR RECOVERY VAULT MODULE (conditionally created with count = 0 by default)
# =============================================================================

module "dr_recovery_vault" {
  count              = var.dr_resource_count
  source             = "../../modules/recovery-vault"
  resource_group_name = azurerm_resource_group.dr_recovery[0].name
  location            = var.dr_location
  environment         = var.environment
  vault_name          = "rsv-mwd-dr"
  soft_delete_enabled = true
  tags                = local.common_tags
}
