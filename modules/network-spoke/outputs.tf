output "spoke_vnet_id"   { value = azurerm_virtual_network.spoke.id }
output "spoke_vnet_name" { value = azurerm_virtual_network.spoke.name }
output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, v in azurerm_subnet.spoke : k => v.id }
}
output "nsg_ids" {
  description = "Map of subnet name to NSG ID"
  value       = { for k, v in azurerm_network_security_group.spoke : k => v.id }
}
output "route_table_id" { value = azurerm_route_table.spoke.id }
