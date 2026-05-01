terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
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
  default = "primary"
}

variable "primary_location" {
  default = "southcentralus"
}

variable "allowed_admin_cidr" {
  default = "10.0.0.0/8"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "vm_admin_username" {
  default = "mwdadmin"
}

variable "ssh_public_key" {
  default   = "REPLACE_WITH_YOUR_SSH_PUBLIC_KEY"
  sensitive = true
}

variable "log_retention_days" {
  default = 30
}

variable "storage_replication_type" {
  default = "LRS"
}

locals {
  common_tags = {
    project     = "mwd-oil-azure-dr"
    environment = var.environment
    owner       = "security-ops"
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-mwd-hub-\${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "hq" {
  name     = "rg-mwd-hq-\${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-mwd-monitoring-\${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "recovery" {
  name     = "rg-mwd-recovery-\${var.environment}"
  location = var.primary_location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-mwd-hub-\${var.environment}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/27"]
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "snet-hub-mgmt-\${var.environment}"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "hq" {
  name                = "vnet-mwd-hq-\${var.environment}"
  location            = azurerm_resource_group.hq.location
  resource_group_name = azurerm_resource_group.hq.name
  address_space       = ["10.10.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "hq_app" {
  name                 = "snet-hq-app-\${var.environment}"
  resource_group_name  = azurerm_resource_group.hq.name
  virtual_network_name = azurerm_virtual_network.hq.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "hq_mgmt" {
  name                 = "snet-hq-mgmt-\${var.environment}"
  resource_group_name  = azurerm_resource_group.hq.name
  virtual_network_name = azurerm_virtual_network.hq.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_network_security_group" "hq_app" {
  name                = "nsg-hq-app-\${var.environment}"
  location            = azurerm_resource_group.hq.location
  resource_group_name = azurerm_resource_group.hq.name
  tags                = local.common_tags

  security_rule {
    name                       = "AllowSSHFromAdmin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_admin_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-mwd-\${var.environment}"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-mwd-\${var.environment}"
  location            = azurerm_resource_group.recovery.location
  resource_group_name = azurerm_resource_group.recovery.name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = local.common_tags
}

resource "azurerm_storage_account" "primary" {
  name                     = "stmwdprimary001"
  resource_group_name      = azurerm_resource_group.hub.name
  location                 = azurerm_resource_group.hub.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  min_tls_version          = "TLS1_2"
  tags                     = local.common_tags
}
