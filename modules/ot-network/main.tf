# =============================================================================
# Module: ot-network
# MWD Oil Co. — OT/IoT Network Security Rules
# Applies strict NSG rules to OT DMZ, OT, and IoT subnets at drill sites.
#
# ARCHITECTURE NOTE:
# This module implements IEC 62443 zone/conduit controls for:
#   - OT DMZ (Security Level 2) — historian, jump hosts
#   - OT Subnet (Security Level 3) — SCADA, DCS, PLCs (conceptual)
#   - IoT Subnet — sensor aggregation gateways
#
# Safety Instrumented Systems (SIS) are air-gapped and NOT represented here.
# =============================================================================

# -----------------------------------------------------------------------------
# OT DMZ NSG — Tightly controlled. IT can reach historian on specific ports.
# No internet access. No access from OT subnet to IT subnet (one-way data flow).
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "ot_dmz" {
  name                = "nsg-${var.site_name}-ot-dmz-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow IT subnet to reach historian on OSIsoft PI / Honeywell Historian ports
  security_rule {
    name                       = "AllowITtoHistorian"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5450", "5451", "443", "80"]
    source_address_prefix      = var.it_subnet_cidr
    destination_address_prefix = "*"
    description                = "Allow IT subnet to reach historian on approved ports only (PI Server: 5450/5451)"
  }

  # Allow admin jump access from management/IT subnet only
  security_rule {
    name                       = "AllowAdminSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_admin_cidr
    destination_address_prefix = "*"
    description                = "Allow SSH from admin CIDR to OT DMZ jump hosts only"
  }

  # Allow OT subnet to push data to historian (unidirectional data push)
  security_rule {
    name                       = "AllowOTtoHistorianIngest"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5450", "5451"]
    source_address_prefix      = "10.40.3.0/24" # OT subnet — override per site if needed
    destination_address_prefix = "*"
    description                = "Allow OT subnet to push historian data (Purdue Level 3 to Level 3.5)"
  }

  # Deny all inbound from internet
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
    description                = "OT DMZ must never be directly reachable from the internet"
  }

  # Deny outbound to internet — OT DMZ must not initiate internet connections
  security_rule {
    name                       = "DenyInternetOutbound"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    description                = "OT DMZ must not make outbound internet connections — IEC 62443 SL2 requirement"
  }
}

resource "azurerm_subnet_network_security_group_association" "ot_dmz" {
  subnet_id                 = var.ot_dmz_subnet_id
  network_security_group_id = azurerm_network_security_group.ot_dmz.id
}

# -----------------------------------------------------------------------------
# OT Subnet NSG — Maximum restriction. No IT access. No internet.
# Only historian-bound outbound data pushes are allowed.
# Represents Purdue Level 3 (site operations / control systems)
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "ot" {
  name                = "nsg-${var.site_name}-ot-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow only outbound data push to OT DMZ historian
  security_rule {
    name                       = "AllowOTtoHistorian"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["5450", "5451"]
    source_address_prefix      = "*"
    destination_address_prefix = "10.40.2.0/24" # OT DMZ subnet
    description                = "Allow SCADA/DCS to push data to historian in OT DMZ — unidirectional"
  }

  # Deny all inbound from IT — IT cannot directly reach OT subnet
  security_rule {
    name                       = "DenyITtoOT"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.it_subnet_cidr
    destination_address_prefix = "*"
    description                = "IT subnet must not directly access OT subnet — all access via OT DMZ jump host"
  }

  # Deny all internet inbound and outbound
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
    description                = "OT subnet has zero internet exposure — IEC 62443 SL3"
  }

  security_rule {
    name                       = "DenyInternetOutbound"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    description                = "OT subnet has zero internet egress — IEC 62443 SL3"
  }
}

resource "azurerm_subnet_network_security_group_association" "ot" {
  subnet_id                 = var.ot_subnet_id
  network_security_group_id = azurerm_network_security_group.ot.id
}

# -----------------------------------------------------------------------------
# IoT Subnet NSG — Sensor aggregation gateways
# Unidirectional: IoT sends to OT DMZ only. No inbound allowed.
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "iot" {
  name                = "nsg-${var.site_name}-iot-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # IoT gateways push telemetry to OT DMZ historian only
  security_rule {
    name                       = "AllowIoTtoOTDMZ"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["1883", "8883", "443"] # MQTT, MQTT over TLS, HTTPS
    source_address_prefix      = "*"
    destination_address_prefix = "10.40.2.0/24" # OT DMZ
    description                = "IoT sensor gateways push MQTT telemetry to OT DMZ aggregator"
  }

  # Deny all inbound — IoT gateways should never receive inbound connections
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "IoT subnet — no inbound connections permitted from any source"
  }

  # Deny internet egress — gateways communicate to OT DMZ only
  security_rule {
    name                       = "DenyInternetOutbound"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    description                = "IoT gateways must not reach the internet directly"
  }
}

resource "azurerm_subnet_network_security_group_association" "iot" {
  subnet_id                 = var.iot_subnet_id
  network_security_group_id = azurerm_network_security_group.iot.id
}
