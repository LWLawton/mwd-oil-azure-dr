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

# =============================================================================
# PRIMARY RESOURCE GROUPS
# =============================================================================

resource "azurerm_resource_group" "hub" {
  name     = "rg-mwd-primary-hub"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "hq" {
  name     = "rg-mwd-primary-hq"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "corpus_christi" {
  name     = "rg-mwd-primary-corpus-christi"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "midland" {
  name     = "rg-mwd-primary-midland"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "drillsite_a" {
  name     = "rg-mwd-primary-drillsite-a"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "drillsite_b" {
  name     = "rg-mwd-primary-drillsite-b"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-mwd-primary-monitoring"
  location = var.primary_location

  tags = local.common_tags
}

resource "azurerm_resource_group" "recovery" {
  name     = "rg-mwd-primary-recovery"
  location = var.primary_location

  tags = local.common_tags
}

# =============================================================================
# PRIMARY NETWORK MODULES
# =============================================================================

module "hub_network" {
  source              = "../../modules/network-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.primary_location
  environment         = var.environment
  hub_vnet_name       = "vnet-mwd-primary-hub"
  hub_address_space   = var.hub_address_space
  gateway_subnet_cidr = var.gateway_subnet_cidr
  mgmt_subnet_cidr    = var.mgmt_subnet_cidr
  shared_subnet_cidr  = var.shared_subnet_cidr
  allowed_admin_cidr  = var.allowed_admin_cidr
  tags                = local.common_tags
}

module "spoke_hq" {
  source              = "../../modules/network-spoke"
  resource_group_name = azurerm_resource_group.hq.name
  location            = var.primary_location
  environment         = var.environment
  spoke_vnet_name     = "vnet-mwd-primary-hq"
  spoke_address_space = var.hq_address_space
  subnets             = var.hq_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  tags                = local.common_tags
}

module "spoke_corpus_christi" {
  source              = "../../modules/network-spoke"
  resource_group_name = azurerm_resource_group.corpus_christi.name
  location            = var.primary_location
  environment         = var.environment
  spoke_vnet_name     = "vnet-mwd-primary-corpus-christi"
  spoke_address_space = var.corpus_christi_address_space
  subnets             = var.branch_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  tags                = local.common_tags
}

module "spoke_midland" {
  source              = "../../modules/network-spoke"
  resource_group_name = azurerm_resource_group.midland.name
  location            = var.primary_location
  environment         = var.environment
  spoke_vnet_name     = "vnet-mwd-primary-midland"
  spoke_address_space = var.midland_address_space
  subnets             = var.branch_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  tags                = local.common_tags
}

module "spoke_drillsite_a" {
  source              = "../../modules/network-spoke"
  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  spoke_vnet_name     = "vnet-mwd-primary-drillsite-a"
  spoke_address_space = var.drillsite_a_address_space
  subnets             = var.drillsite_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  tags                = local.common_tags
}

module "spoke_drillsite_b" {
  source              = "../../modules/network-spoke"
  resource_group_name = azurerm_resource_group.drillsite_b.name
  location            = var.primary_location
  environment         = var.environment
  spoke_vnet_name     = "vnet-mwd-primary-drillsite-b"
  spoke_address_space = var.drillsite_b_address_space
  subnets             = var.drillsite_subnets
  hub_vnet_id         = module.hub_network.hub_vnet_id
  tags                = local.common_tags
}

# =============================================================================
# PRIMARY VM MODULES
# =============================================================================

module "vm_hq_app" {
  source              = "../../modules/compute-vm"
  resource_group_name = azurerm_resource_group.hq.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-primary-hq-app"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_hq.subnet_ids["app"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

module "vm_hq_mgmt" {
  source              = "../../modules/compute-vm"
  resource_group_name = azurerm_resource_group.hq.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-primary-hq-mgmt"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_hq.subnet_ids["mgmt"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

module "vm_drillsite_a_historian" {
  source              = "../../modules/compute-vm"
  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-primary-drillsite-a-historian"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_drillsite_a.subnet_ids["ot"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

module "vm_drillsite_a_jump" {
  source              = "../../modules/compute-vm"
  resource_group_name = azurerm_resource_group.drillsite_a.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-primary-drillsite-a-jump"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_drillsite_a.subnet_ids["it"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

module "vm_drillsite_b_historian" {
  source              = "../../modules/compute-vm"
  resource_group_name = azurerm_resource_group.drillsite_b.name
  location            = var.primary_location
  environment         = var.environment
  vm_name             = "vm-mwd-primary-drillsite-b-historian"
  vm_size             = var.vm_size
  subnet_id           = module.spoke_drillsite_b.subnet_ids["ot"]
  admin_username      = var.vm_admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

# =============================================================================
# PRIMARY MONITORING MODULE
# =============================================================================

module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = var.primary_location
  environment         = var.environment
  workspace_name      = "law-mwd-primary"
  log_retention_days  = var.log_retention_days
  tags                = local.common_tags
}

# =============================================================================
# PRIMARY RECOVERY VAULT MODULE
# =============================================================================

module "recovery_vault" {
  source              = "../../modules/recovery-vault"
  resource_group_name = azurerm_resource_group.recovery.name
  location            = var.primary_location
  environment         = var.environment
  vault_name          = "rsv-mwd-primary"
  soft_delete_enabled = true
  tags                = local.common_tags
}

# =============================================================================
# PRIMARY STORAGE MODULES
# =============================================================================

module "storage_primary" {
  source              = "../../modules/storage"
  resource_group_name = azurerm_resource_group.recovery.name
  location            = var.primary_location
  environment         = var.environment
  storage_name        = "stmwdprimary"
  replication_type    = var.storage_replication_type
  tags                = local.common_tags
}

module "storage_backup" {
  source              = "../../modules/storage"
  resource_group_name = azurerm_resource_group.recovery.name
  location            = var.primary_location
  environment         = var.environment
  storage_name        = "stmwdprimarybackup"
  replication_type    = var.storage_replication_type
  tags                = local.common_tags
}