# =============================================================================
# Module: rbac-groups
# MWD Oil Co. — RBAC Group Design Documentation
# =============================================================================
# No real Entra ID groups or role assignments are deployed by this module.
# This module exists to document the RBAC group design and serve as a
# placeholder for when real group object IDs are available.
#
# To implement: Replace placeholder object_ids with real Entra ID group IDs
# from your tenant. These are available in Entra ID > Groups.
# =============================================================================

# -----------------------------------------------------------------------------
# RBAC Role Assignments — Commented Out (No Real Object IDs)
# -----------------------------------------------------------------------------
# Uncomment and replace object_id values with real Entra ID group IDs.
#
# resource "azurerm_role_assignment" "cloud_admins" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID"
#   role_definition_name = "Owner"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-cloud-admins
#   # Use: Break-glass only. Enable PIM for Just-In-Time activation.
#   # Warning: Owner at subscription scope is very broad — use sparingly.
# }
#
# resource "azurerm_role_assignment" "security_ops" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID"
#   role_definition_name = "Security Reader"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-security-ops
#   # Additional Sentinel Contributor role assigned at workspace scope
# }
#
# resource "azurerm_role_assignment" "sentinel_contributor" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID/resourceGroups/rg-mwd-monitoring-primary"
#   role_definition_name = "Microsoft Sentinel Contributor"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-security-ops
# }
#
# resource "azurerm_role_assignment" "network_ops" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID"
#   role_definition_name = "Network Contributor"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-network-ops — scoped to network resource groups only in production
# }
#
# resource "azurerm_role_assignment" "vm_ops" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID"
#   role_definition_name = "Virtual Machine Contributor"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-vm-ops
# }
#
# resource "azurerm_role_assignment" "readonly" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID"
#   role_definition_name = "Reader"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-readonly — all staff, auditors
# }
#
# resource "azurerm_role_assignment" "ot_admins" {
#   scope                = "/subscriptions/REPLACE_WITH_SUBSCRIPTION_ID/resourceGroups/rg-mwd-drillsite-a-primary"
#   role_definition_name = "Contributor"
#   principal_id         = "REPLACE_WITH_ENTRA_GROUP_OBJECT_ID"
#   # Group: mwd-ot-admins — OT resource groups only, not subscription-wide
# }

# Placeholder resource to allow module to be referenced without errors
resource "null_resource" "rbac_placeholder" {
  triggers = {
    environment = var.environment
    note        = "Replace this module with real azurerm_role_assignment resources when Entra ID group IDs are available"
  }
}
