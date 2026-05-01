output "vm_id"             { value = azurerm_linux_virtual_machine.vm.id }
output "vm_name"           { value = azurerm_linux_virtual_machine.vm.name }
output "private_ip_address"{ value = azurerm_network_interface.vm.private_ip_address }
output "nic_id"            { value = azurerm_network_interface.vm.id }
