output "sentinel_workspace_id" {
  description = "Log Analytics workspace ID with Sentinel enabled"
  value       = azurerm_sentinel_log_analytics_workspace_onboarding.main.workspace_id
}

output "alert_rule_ids" {
  description = "Map of Sentinel alert rule IDs"
  value = {
    ssh_brute_force              = azurerm_sentinel_alert_rule_scheduled.ssh_brute_force.id
    sudo_escalation              = azurerm_sentinel_alert_rule_scheduled.sudo_escalation.id
    ot_dmz_unexpected_outbound   = azurerm_sentinel_alert_rule_scheduled.ot_dmz_unexpected_outbound.id
    mass_file_deletion           = azurerm_sentinel_alert_rule_scheduled.mass_file_deletion.id
  }
}
