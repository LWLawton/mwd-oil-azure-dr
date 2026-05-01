# =============================================================================
# Module: monitoring
# MWD Oil Co. — Log Analytics Workspace
# =============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags

  # First 5GB/day is free under PerGB2018 SKU
  # Monitor ingestion in Azure Cost Management to avoid surprise charges
}

# =============================================================================
# Diagnostic settings and data sources are configured per-resource
# and attached to this workspace ID via outputs
# =============================================================================

# Windows Event Log collection (for any future Windows VMs)
resource "azurerm_log_analytics_datasource_windows_event" "system" {
  name                = "windows-system-events"
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.main.name
  event_log_name      = "System"
  event_types         = ["Error", "Warning"]
}

resource "azurerm_log_analytics_datasource_windows_event" "security" {
  name                = "windows-security-events"
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.main.name
  event_log_name      = "Security"
  event_types         = ["Error", "Warning", "Information"]
}

# Linux Syslog collection
resource "azurerm_log_analytics_datasource_windows_performance_counter" "cpu" {
  name                = "linux-cpu-perf"
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.main.name
  object_name         = "Processor"
  instance_name       = "*"
  counter_name        = "% Processor Time"
  interval_seconds    = 60
}
