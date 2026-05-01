# =============================================================================
# MWD Oil Co. — DR Environment Locals
# =============================================================================

locals {
  common_tags = {
    project     = "mwd-oil-azure-dr"
    environment = var.environment
    owner       = "security-ops"
    managed_by  = "terraform"
    company     = "MWD-Oil-Co"
  }
}
