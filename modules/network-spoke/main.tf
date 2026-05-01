# =============================================================================
# Module: network-spoke
# MWD Oil Co. — Spoke VNet, Dynamic Subnets, NSGs, Hub Peering
# =============================================================================

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-mwd-${var.spoke_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Dynamic subnet creation from the subnets variable map
resource "azurerm_subnet" "spoke" {
  for_each = var.subnets

  name                 = "snet-${var.spoke_name}-${each.key}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]
}

# NSG per subnet — one NSG applied to each dynamically created subnet
resource "azurerm_network_security_group" "spoke" {
  for_each = var.subnets

  name                = "nsg-${var.spoke_name}-${each.key}-${var.environment}"
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
    description                = "Allow SSH from approved admin CIDR. Replace with jump host or VPN CIDR."
  }

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    description                = "Allow intra-VNet traffic (hub-to-spoke)"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    description                = "Required for Azure health probes"
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
    description                = "Deny all inbound internet traffic — no direct internet exposure"
  }
}

resource "azurerm_subnet_network_security_group_association" "spoke" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.spoke[each.key].id
  network_security_group_id = azurerm_network_security_group.spoke[each.key].id
}

# =============================================================================
# VNet Peering — Spoke to Hub
# =============================================================================

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-${var.spoke_name}-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  # Set use_remote_gateways = true when VPN Gateway is deployed in hub
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-${var.spoke_name}"
  resource_group_name       = var.hub_resource_group
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  # Set allow_gateway_transit = true when VPN Gateway is deployed
}

# =============================================================================
# Route Table Placeholder
# In production, add UDRs to force traffic through a hub NVA or firewall
# =============================================================================

resource "azurerm_route_table" "spoke" {
  name                          = "rt-${var.spoke_name}-${var.environment}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false
  tags                          = var.tags

  # Example route — force internet traffic through hub (NVA/Firewall placeholder)
  # Uncomment and update next_hop_in_ip_address when a hub NVA is deployed:
  # route {
  #   name                   = "force-internet-via-hub"
  #   address_prefix         = "0.0.0.0/0"
  #   next_hop_type          = "VirtualAppliance"
  #   next_hop_in_ip_address = "REPLACE_WITH_HUB_NVA_IP"
  # }
}
