# =============================================================================
# Module: storage
# MWD Oil Co. — Storage Account with Versioning and Soft Delete
# =============================================================================

resource "azurerm_storage_account" "main" {
  name                     = lower(replace(var.storage_account_name, "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security hardening
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true # Set to false when using Entra ID auth only

  # Blob service properties
  blob_properties {
    versioning_enabled = var.enable_versioning

    dynamic "delete_retention_policy" {
      for_each = var.enable_soft_delete ? [1] : []
      content {
        days = var.soft_delete_retention
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.enable_soft_delete ? [1] : []
      content {
        days = var.soft_delete_retention
      }
    }
  }

  tags = var.tags
}

# Network rules — restrict access to approved networks only
# Default deny all public access in production
resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id = azurerm_storage_account.main.id
  default_action     = "Allow" # Change to "Deny" in production with VNet service endpoints
  bypass             = ["AzureServices", "Logging", "Metrics"]
  # ip_rules = ["REPLACE_WITH_APPROVED_CIDR"]  # Uncomment for production lockdown
  # virtual_network_subnet_ids = []             # Add subnet IDs for service endpoint access
}
