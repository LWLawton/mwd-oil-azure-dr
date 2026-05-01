# =============================================================================
# Module: linux-vm
# MWD Oil Co. — Ubuntu 22.04 LTS Linux VM
# No public IPs by default. SSH access via hub management subnet only.
# =============================================================================

resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public IP — access via VPN or hub jump host only
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  # SSH key auth only — password auth disabled
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.vm.id]

  os_disk {
    name                 = "osdisk-${var.vm_name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Boot diagnostics — uses managed storage (no storage account required)
  boot_diagnostics {}

  # Identity block omitted — managed identities not used in this version
  # For production: add system-assigned managed identity for Log Analytics agent

  lifecycle {
    ignore_changes = [
      # Ignore image version changes to prevent unplanned VM replacements
      source_image_reference
    ]
  }
}

# Managed data disk — optional, attached if data_disk_size_gb > 0
resource "azurerm_managed_disk" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  name                 = "datadisk-${var.vm_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  managed_disk_id    = azurerm_managed_disk.data[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = 0
  caching            = "ReadWrite"
}
