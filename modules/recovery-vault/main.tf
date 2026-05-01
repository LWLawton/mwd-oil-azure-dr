# =============================================================================
# Module: recovery-vault
# MWD Oil Co. — Recovery Services Vault + Azure Site Recovery (conceptual)
# =============================================================================

resource "azurerm_recovery_services_vault" "main" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = var.soft_delete_enabled
  tags                = var.tags

  # Immutability — strongly recommended for ransomware resilience
  # Uncomment after initial deployment if you want to lock backup policy
  # immutability = "Locked"  # WARNING: Locked immutability cannot be disabled
}

# =============================================================================
# VM Backup Policy — Daily snapshots, 30-day retention
# =============================================================================

resource "azurerm_backup_policy_vm" "daily" {
  name                = "policy-vm-daily-${var.environment}"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  timezone = "Central Standard Time"

  backup {
    frequency = "Daily"
    time      = "02:00" # 2AM CST — off-peak for South Texas operations
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 12
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = 6
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

# =============================================================================
# Azure Site Recovery — Replication Fabric
# The replication vault in the DR region acts as the ASR target.
# ASR replication items (individual VMs) are configured here as placeholders.
#
# In practice, ASR VM replication is configured via the Azure Portal or
# az recoveryservices command after initial infrastructure deployment.
#
# The azurerm_site_recovery_* resources require additional setup:
# - Primary fabric (source region)
# - DR fabric (target region, in DR vault)
# - Protection containers
# - Replication policies
#
# These are documented here as placeholders — uncomment and configure
# when your Azure subscription is ready for ASR setup.
# =============================================================================

# resource "azurerm_site_recovery_fabric" "primary" {
#   name                = "fabric-primary-${var.environment}"
#   resource_group_name = var.resource_group_name
#   recovery_vault_name = azurerm_recovery_services_vault.main.name
#   location            = var.location
# }

# resource "azurerm_site_recovery_protection_container" "primary" {
#   name                 = "container-primary-${var.environment}"
#   resource_group_name  = var.resource_group_name
#   recovery_vault_name  = azurerm_recovery_services_vault.main.name
#   recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
# }

# resource "azurerm_site_recovery_replication_policy" "default" {
#   name                                                 = "policy-asr-default-${var.environment}"
#   resource_group_name                                  = var.resource_group_name
#   recovery_vault_name                                  = azurerm_recovery_services_vault.main.name
#   recovery_point_retention_in_minutes                  = 24 * 60  # 24 hours of recovery points
#   application_consistent_snapshot_frequency_in_minutes = 60       # App-consistent snapshot hourly
# }
