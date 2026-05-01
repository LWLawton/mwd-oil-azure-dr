# =============================================================================
# MWD Oil Co. — Azure Hybrid DR Reference Architecture
# DR Environment — West US 3
# =============================================================================
# Portfolio Project | Loren Lawton, CISSP
# FICTIONAL REFERENCE ARCHITECTURE — Do not deploy without reviewing COST_CONTROL.md
#
# DR RESOURCES DEFAULT TO count = 0 — THEY WILL NOT DEPLOY UNLESS YOU CHANGE THIS
# Change count = 0 to count = 1 to enable DR resources during a declared failover
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # LOCAL STATE — For demo/lab use only
  # See environments/primary/BACKEND_GUIDE.md for remote state configuration
  # backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    recovery_services {
      purge_soft_deleted_backup_items_on_destroy = true
    }
  }
}

locals {
  common_tags = {
    project     = "mwd-oil-azure-dr"
    environment = var.environment
    owner       = "security-ops"
    managed_by  = "terraform"
    company     = "MWD-Oil-Co"
    region-role = "disaster-recovery"
  }
}

# =============================================================================
# DR RESOURCE GROUPS
# count = 0 means these will NOT be created by default
# Change to count = 1 to enable during a declared DR event
# =============================================================================

resource "azurerm_resource_group" "dr_hub" {
  # DR powered down — change count to 1 to enable during declared failover
  count    = 0
  name     = "rg-mwd-hub-${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "dr_hq" {
  count    = 0 # DR powered down — change to 1 to enable
  name     = "rg-mwd-hq-${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "dr_monitoring" {
  count    = 0 # DR powered down — change to 1 to enable
  name     = "rg-mwd-monitoring-${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "dr_recovery" {
  count    = 0 # DR powered down — change to 1 to enable
  name     = "rg-mwd-recovery-${var.environment}"
  location = var.dr_location
  tags     = local.common_tags
}

# =============================================================================
# DR HUB NETWORK
# count = 0 — change to 1 to enable
# =============================================================================

module "dr_hub_network" {
  # DR powered down — change count to 1 to enable
  count  = 0
  source = "../../modules/network-hub"

  resource_group_name = azurerm_resource_group.dr_hub[0].name
  location            = var.dr_location
  environment         = var.environment
  hub_vnet_name       = "vnet-mwd-hub-${var.environment}"
  hub_address_space   = var.dr_hub_address_space
  gateway_subnet_cidr = var.dr_gateway_subnet_cidr
  mgmt_subnet_cidr    = var.dr_mgmt_subnet_cidr
  shared_subnet_cidr  = var.dr_shared_subnet_cidr
  tags                = local.common_tags
}

# =============================================================================
# DR SPOKE — HQ Failover
# count = 0 — change to 1 to enable
# =============================================================================

module "dr_spoke_hq" {
  count  = 0 # DR powered down — change to 1 to enable
  source = "../../modules/network-spoke"

  resource_group_name = azurerm_resource_group.dr_hq[0].name
  location            = var.dr_location
  environment         = var.environment
  spoke_name          = "hq"
  vnet_address_space  = var.dr_hq_address_space
  subnets             = var.dr_hq_subnets
  hub_vnet_id         = module.dr_hub_network[0].hub_vnet_id
  hub_vnet_name       = module.dr_hub_network[0].hub_vnet_name
  hub_resource_group  = azurerm_resource_group.dr_hub[0].name
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

# =============================================================================
# DR MONITORING — Independent Log Analytics in DR Region
# count = 0 — change to 1 to enable
# Note: DR monitoring should be independent of primary — do not depend on primary LA
# =============================================================================

module "dr_monitoring" {
  count  = 0 # DR powered down — change to 1 to enable
  source = "../../modules/monitoring"

  resource_group_name = azurerm_resource_group.dr_monitoring[0].name
  location            = var.dr_location
  environment         = var.environment
  workspace_name      = "law-mwd-${var.environment}"
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags
}

# =============================================================================
# DR SENTINEL
# count = 0 — change to 1 to enable
# =============================================================================

module "dr_sentinel" {
  count  = 0 # DR powered down — change to 1 to enable
  source = "../../modules/sentinel"

  resource_group_name = azurerm_resource_group.dr_monitoring[0].name
  workspace_id        = module.dr_monitoring[0].workspace_id
  workspace_name      = module.dr_monitoring[0].workspace_name
  environment         = var.environment
  tags                = local.common_tags
}

# =============================================================================
# DR RECOVERY VAULT
# count = 0 — change to 1 to enable
# This vault is the ASR target for VM replication from primary
# =============================================================================

module "dr_recovery_vault" {
  count  = 0 # DR powered down — change to 1 to enable
  source = "../../modules/recovery-vault"

  resource_group_name = azurerm_resource_group.dr_recovery[0].name
  location            = var.dr_location
  environment         = var.environment
  vault_name          = "rsv-mwd-${var.environment}"
  soft_delete_enabled = true
  tags                = local.common_tags
}

# =============================================================================
# DR STORAGE
# count = 0 — change to 1 to enable
# =============================================================================

module "dr_storage" {
  count  = 0 # DR powered down — change to 1 to enable
  source = "../../modules/storage"

  resource_group_name   = azurerm_resource_group.dr_hub[0].name
  location              = var.dr_location
  environment           = var.environment
  storage_account_name  = "stmwddr${var.environment}"
  replication_type      = "LRS" # LRS in DR region — GRS handled by primary account
  enable_versioning     = true
  enable_soft_delete    = true
  soft_delete_retention = 30
  tags                  = local.common_tags
}
