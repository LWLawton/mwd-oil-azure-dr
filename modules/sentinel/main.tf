# =============================================================================
# Module: sentinel
# MWD Oil Co. — Microsoft Sentinel Onboarding
# =============================================================================
# Sentinel is enabled by adding a solution to an existing Log Analytics workspace.
# This module onboards Sentinel and configures foundational settings.
# =============================================================================

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id                 = var.workspace_id
  customer_managed_key_enabled = false
  # Set customer_managed_key_enabled = true and configure CMK for high-security environments
}

# =============================================================================
# Sentinel Analytics Rules — Built-in Scheduled Rules
# These rules provide baseline detection for common threats
# =============================================================================

# Brute force detection against Linux VMs
resource "azurerm_sentinel_alert_rule_scheduled" "ssh_brute_force" {
  name                       = "rule-ssh-brute-force-${var.environment}"
  log_analytics_workspace_id = var.workspace_id
  display_name               = "MWD - SSH Brute Force Attempt Detected"
  severity                   = "Medium"
  enabled                    = true

  query = <<-EOT
    Syslog
    | where Facility == "auth" and SyslogMessage has "Failed password"
    | summarize FailedAttempts = count() by HostName, HostIP, bin(TimeGenerated, 5m)
    | where FailedAttempts > 10
    | extend AlertDetail = strcat("Host: ", HostName, " | Failures: ", FailedAttempts)
  EOT

  query_frequency      = "PT5M"
  query_period         = "PT15M"
  trigger_operator     = "GreaterThan"
  trigger_threshold    = 0
  suppression_enabled  = false
  suppression_duration = "PT1H"

  incident_configuration {
    create_incident = true
    grouping {
      enabled                 = true
      lookback_duration       = "PT1H"
      reopen_closed_incident  = false
      entity_matching_method  = "AnyAlert"
    }
  }
}

# Privilege escalation detection
resource "azurerm_sentinel_alert_rule_scheduled" "sudo_escalation" {
  name                       = "rule-sudo-escalation-${var.environment}"
  log_analytics_workspace_id = var.workspace_id
  display_name               = "MWD - Suspicious sudo Escalation on Linux VM"
  severity                   = "High"
  enabled                    = true

  query = <<-EOT
    Syslog
    | where Facility == "authpriv" and SyslogMessage has "sudo"
    | where SyslogMessage has_any ("COMMAND", "authentication failure")
    | project TimeGenerated, HostName, HostIP, SyslogMessage
  EOT

  query_frequency   = "PT15M"
  query_period      = "PT1H"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  incident_configuration {
    create_incident = true
    grouping {
      enabled                = true
      lookback_duration      = "PT1H"
      reopen_closed_incident = false
      entity_matching_method = "AnyAlert"
    }
  }
}

# OT DMZ unexpected outbound connection
resource "azurerm_sentinel_alert_rule_scheduled" "ot_dmz_unexpected_outbound" {
  name                       = "rule-ot-dmz-outbound-${var.environment}"
  log_analytics_workspace_id = var.workspace_id
  display_name               = "MWD - Unexpected Outbound from OT DMZ Subnet"
  severity                   = "High"
  enabled                    = true

  query = <<-EOT
    AzureNetworkAnalytics_CL
    | where SubType_s == "FlowLog"
    | where FlowDirection_s == "O"
    | where SrcIP_s startswith "10.40.2." or SrcIP_s startswith "10.50.2."
    | where DestPublicIPs_s != "" and DestPublicIPs_s != "-"
    | project TimeGenerated, SrcIP_s, DestPublicIPs_s, DestPort_d, FlowStatus_s
    | where FlowStatus_s == "A"
  EOT

  query_frequency   = "PT5M"
  query_period      = "PT15M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  incident_configuration {
    create_incident = true
    grouping {
      enabled                = true
      lookback_duration      = "PT30M"
      reopen_closed_incident = true
      entity_matching_method = "AnyAlert"
    }
  }
}

# Mass file deletion / potential ransomware indicator
resource "azurerm_sentinel_alert_rule_scheduled" "mass_file_deletion" {
  name                       = "rule-mass-file-deletion-${var.environment}"
  log_analytics_workspace_id = var.workspace_id
  display_name               = "MWD - Mass File Deletion Detected (Ransomware Indicator)"
  severity                   = "High"
  enabled                    = true

  query = <<-EOT
    Syslog
    | where SyslogMessage has_any ("rm -rf", "shred", "wipe", "cipher")
    | summarize count() by HostName, bin(TimeGenerated, 5m)
    | where count_ > 5
  EOT

  query_frequency   = "PT5M"
  query_period      = "PT15M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  incident_configuration {
    create_incident = true
    grouping {
      enabled                = true
      lookback_duration      = "PT15M"
      reopen_closed_incident = true
      entity_matching_method = "AnyAlert"
    }
  }
}
