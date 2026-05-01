# =============================================================================
# MWD Oil Co. — Primary Environment Outputs
# =============================================================================

output "resource_group_names" {
  description = "All resource group names in the primary environment"
  value = {
    hub            = azurerm_resource_group.hub.name
    hq             = azurerm_resource_group.hq.name
    corpus_christi = azurerm_resource_group.corpus_christi.name
    midland        = azurerm_resource_group.midland.name
    drillsite_a    = azurerm_resource_group.drillsite_a.name
    drillsite_b    = azurerm_resource_group.drillsite_b.name
    monitoring     = azurerm_resource_group.monitoring.name
    recovery       = azurerm_resource_group.recovery.name
  }
}

output "hub_vnet_id" {
  description = "Primary hub VNet resource ID"
  value       = module.hub_network.hub_vnet_id
}

output "hub_vnet_name" {
  description = "Primary hub VNet name"
  value       = module.hub_network.hub_vnet_name
}

output "spoke_vnet_ids" {
  description = "Map of spoke VNet resource IDs"
  value = {
    hq             = module.spoke_hq.spoke_vnet_id
    corpus_christi = module.spoke_corpus_christi.spoke_vnet_id
    midland        = module.spoke_midland.spoke_vnet_id
    drillsite_a    = module.spoke_drillsite_a.spoke_vnet_id
    drillsite_b    = module.spoke_drillsite_b.spoke_vnet_id
  }
}

output "hq_subnet_ids" {
  description = "HQ spoke subnet IDs"
  value       = module.spoke_hq.subnet_ids
}

output "drillsite_a_subnet_ids" {
  description = "Drill Site A subnet IDs"
  value       = module.spoke_drillsite_a.subnet_ids
}

output "drillsite_b_subnet_ids" {
  description = "Drill Site B subnet IDs"
  value       = module.spoke_drillsite_b.subnet_ids
}

output "vm_private_ips" {
  description = "Private IP addresses for all deployed VMs"
  value = {
    hq_app              = module.vm_hq_app.private_ip_address
    hq_mgmt             = module.vm_hq_mgmt.private_ip_address
    drillsite_a_historian = module.vm_drillsite_a_historian.private_ip_address
    drillsite_a_jump    = module.vm_drillsite_a_jump.private_ip_address
    drillsite_b_historian = module.vm_drillsite_b_historian.private_ip_address
  }
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = module.monitoring.workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.monitoring.workspace_name
}

output "log_analytics_primary_key" {
  description = "Log Analytics workspace primary key (sensitive)"
  value       = module.monitoring.primary_shared_key
  sensitive   = true
}

output "recovery_vault_name" {
  description = "Recovery Services Vault name"
  value       = module.recovery_vault.vault_name
}

output "recovery_vault_id" {
  description = "Recovery Services Vault resource ID"
  value       = module.recovery_vault.vault_id
}

output "storage_account_primary_name" {
  description = "Primary storage account name"
  value       = module.storage_primary.storage_account_name
}

output "storage_account_backup_name" {
  description = "Backup storage account name"
  value       = module.storage_backup.storage_account_name
}

output "failover_notes" {
  description = "Summary of failover-relevant resource identifiers"
  value = <<-EOT
    ============================================================
    MWD Oil Co. — Primary Environment Failover Reference
    ============================================================
    Primary Region:    ${var.primary_location}
    Hub VNet:          ${module.hub_network.hub_vnet_name}
    Log Analytics:     ${module.monitoring.workspace_name}
    Recovery Vault:    ${module.recovery_vault.vault_name}

    To initiate DR failover:
    1. Navigate to environments/dr/
    2. Set count = 1 for required DR resources
    3. Run: terraform init -backend=false && terraform apply
    4. Follow FAILOVER_FAILBACK.md procedures

    RTO Target: 4 hours | RPO Target: 15 minutes
    ============================================================
  EOT
}
