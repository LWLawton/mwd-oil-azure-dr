# =============================================================================
# MWD Oil Co. — DR Environment Outputs
# Note: Most outputs will be empty until DR resources are enabled (count = 1)
# =============================================================================

output "dr_status" {
  description = "DR environment deployment status"
  value       = "DR resources are set to count = 0 by default. Change to count = 1 in main.tf to enable."
}

output "dr_location" {
  description = "DR region"
  value       = var.dr_location
}

output "dr_hub_vnet_id" {
  description = "DR hub VNet ID (empty if DR is powered down)"
  value       = length(module.dr_hub_network) > 0 ? module.dr_hub_network[0].hub_vnet_id : "DR not enabled"
}

output "dr_log_analytics_workspace_id" {
  description = "DR Log Analytics workspace ID (empty if DR is powered down)"
  value       = length(module.dr_monitoring) > 0 ? module.dr_monitoring[0].workspace_id : "DR not enabled"
}

output "dr_recovery_vault_name" {
  description = "DR Recovery Services Vault name (empty if DR is powered down)"
  value       = length(module.dr_recovery_vault) > 0 ? module.dr_recovery_vault[0].vault_name : "DR not enabled"
}

output "dr_failover_instructions" {
  description = "Instructions for enabling DR resources"
  value       = <<-EOT
    ============================================================
    MWD Oil Co. — DR Environment Activation Instructions
    ============================================================
    DR Region:    ${var.dr_location}
    DR Status:    POWERED DOWN (count = 0)

    To activate DR environment:
    1. Declare DR event per DR_RUNBOOK.md
    2. Edit environments/dr/main.tf
    3. Change count = 0 to count = 1 for required resources
    4. Run: terraform apply
    5. Follow FAILOVER_FAILBACK.md Phase 3 onward

    Priority order for enabling:
    1. dr_hub (resource groups + hub network)
    2. dr_monitoring (Log Analytics + Sentinel)
    3. dr_recovery_vault (ASR target)
    4. dr_spoke_hq (HQ failover network)
    5. dr_storage (DR storage accounts)

    RTO Target: 4 hours from declaration
    ============================================================
  EOT
}
