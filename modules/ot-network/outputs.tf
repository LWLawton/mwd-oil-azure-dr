output "ot_dmz_nsg_id" { value = azurerm_network_security_group.ot_dmz.id }
output "ot_nsg_id"     { value = azurerm_network_security_group.ot.id }
output "iot_nsg_id"    { value = azurerm_network_security_group.iot.id }
