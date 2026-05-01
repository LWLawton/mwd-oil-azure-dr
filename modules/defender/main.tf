# =============================================================================
# Module: defender
# MWD Oil Co. — Microsoft Defender for Cloud Configuration
# =============================================================================
# Defender for Cloud free tier is enabled by default on all Azure subscriptions.
# This module enables enhanced Defender plans for specific resource types.
#
# COST WARNING: Defender plans have per-resource costs. Review before enabling.
# Defender for Servers Plan 2: ~$15/server/month
# Defender for Storage:        ~$10/storage account/month
# Defender for Key Vault:      Not used in this project
# =============================================================================

# Defender for Servers — Plan 1 (lower cost, basic protection)
# Plan 1: ~$5/server/month | Plan 2: ~$15/server/month
resource "azurerm_security_center_subscription_pricing" "servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P1" # P1 = Plan 1 (~$5/server/mo), P2 = Plan 2 (~$15/server/mo)
}

# Defender for Storage — detects malicious activity in storage accounts
resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

# Defender for DNS — detects C2 over DNS, data exfiltration via DNS
resource "azurerm_security_center_subscription_pricing" "dns" {
  tier          = "Standard"
  resource_type = "Dns"
  # Low cost — recommended for energy sector environments
}

# Security Center Contact — notifications go to the SOC team
resource "azurerm_security_center_contact" "soc" {
  # Replace with real SOC email in production
  # Do not commit real email addresses to public repositories
  email               = "soc-alerts@mwdoilco.example.com"
  phone               = "+1-210-555-0100" # Placeholder — San Antonio area code
  alert_notifications = true
  alerts_to_admins    = true
}

# Auto-provisioning of monitoring agent on VMs
resource "azurerm_security_center_auto_provisioning" "mma" {
  auto_provision = "On"
  # Enables automatic deployment of Azure Monitor Agent on new VMs
}

# Defender for Cloud workspace configuration — use the project Log Analytics workspace
# This is configured at the environment level via workspace_id variable
# resource "azurerm_security_center_workspace" "main" {
#   scope        = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID"
#   workspace_id = var.log_analytics_workspace_id
# }
