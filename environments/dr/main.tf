# =============================================================================
# MWD Oil Co.
# Azure Hybrid DR Reference Architecture
# Disaster Recovery Environment
# East US 2
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "dr_rg" {
  name     = "rg-mwd-dr"
  location = "East US 2"

  tags = {
    Environment = "DisasterRecovery"
    Project     = "MWD-Oil-DR"
  }
}

resource "azurerm_virtual_network" "dr_vnet" {
  name                = "vnet-mwd-dr"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.dr_rg.location
  resource_group_name = azurerm_resource_group.dr_rg.name
}

resource "azurerm_subnet" "dr_security_subnet" {
  name                 = "snet-dr-security"
  resource_group_name  = azurerm_resource_group.dr_rg.name
  virtual_network_name = azurerm_virtual_network.dr_vnet.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_network_security_group" "dr_security_nsg" {
  name                = "nsg-dr-security"
  location            = azurerm_resource_group.dr_rg.location
  resource_group_name = azurerm_resource_group.dr_rg.name

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
