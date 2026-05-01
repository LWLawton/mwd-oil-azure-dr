output "hub_vnet_id"          { value = azurerm_virtual_network.hub.id }
output "hub_vnet_name"        { value = azurerm_virtual_network.hub.name }
output "gateway_subnet_id"    { value = azurerm_subnet.gateway.id }
output "mgmt_subnet_id"       { value = azurerm_subnet.management.id }
output "shared_subnet_id"     { value = azurerm_subnet.shared_services.id }
output "vpn_gateway_pip"      { value = azurerm_public_ip.vpn_gateway.ip_address }
