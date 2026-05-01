# =============================================================================
# Module: network-hub
# MWD Oil Co. — Hub VNet, Subnets, and VPN Gateway Placeholder
# =============================================================================

resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.hub_address_space]
  tags                = var.tags
}

# GatewaySubnet — required name for VPN/ExpressRoute gateway
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_cidr]
  # Note: GatewaySubnet cannot have an NSG associated with it
}

resource "azurerm_subnet" "management" {
  name                 = "snet-hub-mgmt-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.mgmt_subnet_cidr]
}

resource "azurerm_subnet" "shared_services" {
  name                 = "snet-hub-shared-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.shared_subnet_cidr]
}

# NSG for hub management subnet
resource "azurerm_network_security_group" "hub_mgmt" {
  name                = "nsg-hub-mgmt-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

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
    description                = "Allow SSH from approved admin CIDR only. Replace with VPN/jump host CIDR."
  }

  security_rule {
    name                       = "DenyAllInboundInternet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Deny all inbound internet traffic to hub management subnet"
  }
}

resource "azurerm_subnet_network_security_group_association" "hub_mgmt" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.hub_mgmt.id
}

# =============================================================================
# VPN Gateway — Placeholder Public IP
# The VPN Gateway resource itself is omitted to avoid ~$140/month cost
# In production, uncomment the azurerm_virtual_network_gateway resource below
# =============================================================================

resource "azurerm_public_ip" "vpn_gateway" {
  name                = "pip-vpngw-hub-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# VPN Gateway — uncomment to deploy (~$140-$270/month depending on SKU)
# resource "azurerm_virtual_network_gateway" "hub_vpn" {
#   name                = "vpngw-hub-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   type                = "Vpn"
#   vpn_type            = "RouteBased"
#   sku                 = "VpnGw1"   # ~$140/month — use Basic (~$27/mo) for lab
#   active_active       = false
#   enable_bgp          = false
#
#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.gateway.id
#   }
#   tags = var.tags
# }

# Local Network Gateways (site-to-site VPN endpoints) — placeholders
# Replace with real on-premises public IPs and BGP ASNs
#
# resource "azurerm_local_network_gateway" "hq_onprem" {
#   name                = "lng-hq-onprem"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   gateway_address     = "REPLACE_WITH_HQ_PUBLIC_IP"
#   address_space       = ["192.168.10.0/24"]  # HQ on-premises LAN
# }
#
# resource "azurerm_local_network_gateway" "corpus_christi_onprem" {
#   name                = "lng-corpuschristi-onprem"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   gateway_address     = "REPLACE_WITH_CC_PUBLIC_IP"
#   address_space       = ["192.168.20.0/24"]
# }

# ExpressRoute placeholder note:
# MWD Oil Co. HQ ExpressRoute circuit would be provisioned by the carrier (e.g., AT&T, Zayo)
# and peered here. ExpressRoute circuits are not deployed in this demo (~$500+/month).
