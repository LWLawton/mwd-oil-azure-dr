# =============================================================================
# MWD Oil Co. — Azure Hybrid DR Reference Architecture
# Primary Environment — South Central US
# =============================================================================
# Portfolio Project | Loren Lawton, CISSP
# FICTIONAL REFERENCE ARCHITECTURE — Do not deploy without reviewing COST_CONTROL.md
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
  # See BACKEND_GUIDE.md to configure remote state with Azure Storage
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
  # subscription_id is read from ARM_SUBSCRIPTION_ID environment variable
  # Do not hard-code subscription IDs in source code
}

# =============================================================================
# RESOURCE GROUPS
# =============================================================================

resource "azurerm_resource_group" "hub" {
  name     = "rg-mwd-hub-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "hq" {
  name     = "rg-mwd-hq-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "corpus_christi" {
  name     = "rg-mwd-corpuschristi-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "midland" {
  name     = "rg-mwd-midland-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "drillsite_a" {
  name     = "rg-mwd-drillsite-a-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "drillsite_b" {
  name     = "rg-mwd-drillsite-b-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-mwd-monitoring-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "recovery" {
  name     = "rg-mwd-recovery-${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

# =============================================================================
# HUB NETWORK
# =============================================================================

module "hub_network" {
  source = "../../modules/network-hub"

  resource_group_name = azurerm_resource_group.hub.name
  location            = var.primary_location
  environment         = var.environment
  hub_vnet_name       = "vnet-mwd-hub-${var.environment}"
  hub_address_space   = var.hub_address_space
  gateway_subnet_cidr = var.gateway_subnet_cidr
  mgmt_subnet_cidr    = var.mgmt_subnet_cidr
  shared_subnet_cidr  = var.shared_subnet_cidr
  tags                = local.common_tags
}

# =============================================================================
# SPOKE NETWORKS
# =============================================================================

module "spoke_hq" {
  source = "../../modules/network-spoke"

  resource_group_name = azurerm_resource_group.hq.name
  location            = var.primary_location
  environment         = var.environment
  spoke_name          = "hq"
  vnet_address_space  = var.hq_address_space
  subnets             = var.hq_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  hub_vnet_name       = module.hub_network.hub_vnet_name
  hub_resource_group  = azurerm_resource_group.hub.name
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

module "spoke_corpus_christi" {
  source = "../../modules/network-spoke"

  resource_group_name = azurerm_resource_group.corpus_christi.name
  location            = var.primary_location
  environment         = var.environment
  spoke_name          = "corpuschristi"
  vnet_address_space  = var.corpus_christi_address_space
  subnets             = var.branch_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  hub_vnet_name       = module.hub_network.hub_vnet_name
  hub_resource_group  = azurerm_resource_group.hub.name
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

module "spoke_midland" {
  source = "../../modules/network-spoke"

  resource_group_name = azurerm_resource_group.midland.name
  location            = var.primary_location
  environment         = var.environment
  spoke_name          = "midland"
  vnet_address_space  = var.midland_address_space
  subnets             = var.branch_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  hub_vnet_name       = module.hub_network.hub_vnet_name
  hub_resource_group  = azurerm_resource_group.hub.name
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

module "spoke_drillsite_a" {
  source = "../../modules/network-spoke"

  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  spoke_name          = "drillsite-a"
  vnet_address_space  = var.drillsite_a_address_space
  subnets             = var.drillsite_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  hub_vnet_name       = module.hub_network.hub_vnet_name
  hub_resource_group  = azurerm_resource_group.hub.name
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

module "spoke_drillsite_b" {
  source = "../../modules/network-spoke"

  resource_group_name = azurerm_resource_group.drillsite_b.name
  location            = var.primary_location
  environment         = var.environment
  spoke_name          = "drillsite-b"
  vnet_address_space  = var.drillsite_b_address_space
  subnets             = var.drillsite_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  hub_vnet_name       = module.hub_network.hub_vnet_name
  hub_resource_group  = azurerm_resource_group.hub.name
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

# =============================================================================
# OT NETWORK MODULE — Drill Sites
# =============================================================================

module "ot_network_drillsite_a" {
  source = "../../modules/ot-network"

  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  site_name           = "drillsite-a"
  spoke_vnet_id       = module.spoke_drillsite_a.spoke_vnet_id
  ot_dmz_subnet_id    = module.spoke_drillsite_a.subnet_ids["ot-dmz"]
  ot_subnet_id        = module.spoke_drillsite_a.subnet_ids["ot"]
  iot_subnet_id       = module.spoke_drillsite_a.subnet_ids["iot"]
  it_subnet_cidr      = var.drillsite_subnets["it"].cidr
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

module "ot_network_drillsite_b" {
  source = "../../modules/ot-network"

  resource_group_name = azurerm_resource_group.drillsite_b.name
  location            = var.primary_location
  environment         = var.environment
  site_name           = "drillsite-b"
  spoke_vnet_id       = module.spoke_drillsite_b.spoke_vnet_id
  ot_dmz_subnet_id    = module.spoke_drillsite_b.subnet_ids["ot-dmz"]
  ot_subnet_id        = module.spoke_drillsite_b.subnet_ids["ot"]
  iot_subnet_id       = module.spoke_drillsite_b.subnet_ids["iot"]
  it_subnet_cidr      = var.drillsite_subnets["it"].cidr
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

# =============================================================================
# VIRTUAL MACHINES — HQ
# =============================================================================

module "vm_hq_app" {
  source = "../../modules/linux-vm"

  resource_group_name = azurerm_resource_group.hq.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-hq-app-01"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_hq.subnet_ids["app"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  os_disk_size_gb     = 64
  tags                = merge(local.common_tags, { role = "app-server", site = "hq" })
}

module "vm_hq_mgmt" {
  source = "../../modules/linux-vm"

  resource_group_name = azurerm_resource_group.hq.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-hq-mgmt-01"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_hq.subnet_ids["mgmt"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  os_disk_size_gb     = 32
  tags                = merge(local.common_tags, { role = "jump-host", site = "hq" })
}

# =============================================================================
# VIRTUAL MACHINES — Drill Site A (OT DMZ)
# =============================================================================

module "vm_drillsite_a_historian" {
  source = "../../modules/linux-vm"

  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-dsa-historian-01"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_drillsite_a.subnet_ids["ot-dmz"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  os_disk_size_gb     = 128
  tags                = merge(local.common_tags, { role = "historian", site = "drillsite-a", zone = "ot-dmz" })
}

module "vm_drillsite_a_jump" {
  source = "../../modules/linux-vm"

  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-dsa-jump-01"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_drillsite_a.subnet_ids["ot-dmz"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  os_disk_size_gb     = 32
  tags                = merge(local.common_tags, { role = "ot-jump-host", site = "drillsite-a", zone = "ot-dmz" })
}

# =============================================================================
# VIRTUAL MACHINES — Drill Site B (OT DMZ)
# =============================================================================

module "vm_drillsite_b_historian" {
  source = "../../modules/linux-vm"

  resource_group_name = azurerm_resource_group.drillsite_b.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-dsb-historian-01"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_drillsite_b.subnet_ids["ot-dmz"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  os_disk_size_gb     = 128
  tags                = merge(local.common_tags, { role = "historian", site = "drillsite-b", zone = "ot-dmz" })
}

# =============================================================================
# MONITORING — Log Analytics + Sentinel
# =============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name        = azurerm_resource_group.monitoring.name
  location                   = var.primary_location
  environment                = var.environment
  workspace_name             = "law-mwd-${var.environment}"
  log_retention_days         = var.log_retention_days
  tags                       = local.common_tags
}

module "sentinel" {
  source = "../../modules/sentinel"

  resource_group_name  = azurerm_resource_group.monitoring.name
  workspace_id         = module.monitoring.workspace_id
  workspace_name       = module.monitoring.workspace_name
  environment          = var.environment
  tags                 = local.common_tags
}

module "defender" {
  source = "../../modules/defender"

  environment = var.environment
}

# =============================================================================
# STORAGE ACCOUNTS
# =============================================================================

module "storage_primary" {
  source = "../../modules/storage"

  resource_group_name      = azurerm_resource_group.hub.name
  location                 = var.primary_location
  environment              = var.environment
  storage_account_name     = "stmwdprimary${var.environment}"
  replication_type         = var.storage_replication_type
  enable_versioning        = true
  enable_soft_delete       = true
  soft_delete_retention    = 30
  tags                     = local.common_tags
}

module "storage_backup" {
  source = "../../modules/storage"

  resource_group_name      = azurerm_resource_group.recovery.name
  location                 = var.primary_location
  environment              = var.environment
  storage_account_name     = "stmwdbackup${var.environment}"
  replication_type         = "GRS"
  enable_versioning        = true
  enable_soft_delete       = true
  soft_delete_retention    = 90
  tags                     = merge(local.common_tags, { purpose = "backup" })
}

# =============================================================================
# RECOVERY SERVICES VAULT
# =============================================================================

module "recovery_vault" {
  source = "../../modules/recovery-vault"

  resource_group_name  = azurerm_resource_group.recovery.name
  location             = var.primary_location
  environment          = var.environment
  vault_name           = "rsv-mwd-${var.environment}"
  soft_delete_enabled  = true
  tags                 = local.common_tags
}

# =============================================================================
# RBAC GROUPS (Conceptual — No real users deployed)
# =============================================================================

module "rbac_groups" {
  source = "../../modules/rbac-groups"

  environment = var.environment
  # No real group IDs — see modules/rbac-groups/README.md for design
}
