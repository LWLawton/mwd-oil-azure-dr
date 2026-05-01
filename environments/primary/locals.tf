# =============================================================================
# MWD Oil Co. — Common Locals
# =============================================================================

locals {
  common_tags = {
    project     = "mwd-oil-azure-dr"
    environment = var.environment
    owner       = "security-ops"
    managed_by  = "terraform"
    company     = "MWD-Oil-Co"
    # IMPORTANT: This is a fictional portfolio project
    # Replace with your organization's tagging standard
  }
}
