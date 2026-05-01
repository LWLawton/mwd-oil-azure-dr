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
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "primary_rg" {
  name     = "rg-mwd-primary"
  location = "South Central US"

  tags = {
    Environment = "Production"
    Project     = "MWD-Oil-DR"
  }
}

resource "azurerm_virtual_network" "primary_vnet" {
  name                = "vnet-mwd-primary"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.primary_rg.location
  resource_group_name = azurerm_resource_group.primary_rg.name
}

resource "azurerm_subnet" "security_subnet" {
  name                 = "snet-security"
  resource_group_name  = azurerm_resource_group.primary_rg.name
  virtual_network_name = azurerm_virtual_network.primary_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "security_nsg" {
  name                = "nsg-security"
  location            = azurerm_resource_group.primary_rg.location
  resource_group_name = azurerm_resource_group.primary_rg.name

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
