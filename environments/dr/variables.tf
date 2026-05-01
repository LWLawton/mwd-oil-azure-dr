# =============================================================================
# MWD Oil Co. — DR Environment Variables
# =============================================================================

variable "environment" {
  description = "Environment label — used in resource naming"
  type        = string
  default     = "dr"
}

variable "dr_resource_count" {
  description = "Count for DR resources. Set to 0 (default/disabled) or 1 (enabled). Must be changed in terraform.tfvars or via CLI (-var dr_resource_count=1)."
  type        = number
  default     = 0
}

variable "dr_location" {
  description = "DR Azure region"
  type        = string
  default     = "westus3"
}

# =============================================================================
# DR NETWORK ADDRESS SPACES
# DR uses 10.100+ range to avoid overlap with primary (10.0-10.50)
# =============================================================================

variable "dr_hub_address_space" {
  description = "DR hub VNet address space"
  type        = string
  default     = "10.100.0.0/16"
}

variable "dr_gateway_subnet_cidr" {
  description = "DR GatewaySubnet CIDR"
  type        = string
  default     = "10.100.0.0/27"
}

variable "dr_mgmt_subnet_cidr" {
  description = "DR hub management subnet CIDR"
  type        = string
  default     = "10.100.1.0/24"
}

variable "dr_shared_subnet_cidr" {
  description = "DR hub shared services subnet CIDR"
  type        = string
  default     = "10.100.2.0/24"
}

variable "dr_hq_address_space" {
  description = "DR HQ spoke VNet address space"
  type        = string
  default     = "10.110.0.0/16"
}

variable "dr_hq_subnets" {
  description = "DR HQ spoke subnet definitions"
  type = map(object({
    cidr = string
  }))
  default = {
    app = {
      cidr = "10.110.1.0/24"
    }
    mgmt = {
      cidr = "10.110.2.0/24"
    }
    data = {
      cidr = "10.110.3.0/24"
    }
  }
}

# =============================================================================
# SECURITY
# =============================================================================

variable "allowed_admin_cidr" {
  description = <<EOT
CIDR range allowed for administrative access in DR environment.
Default: 10.0.0.0/8 (all RFC1918).
Replace with VPN or jump host CIDR in production.
EOT
  type    = string
  default = "10.0.0.0/8"
}

# =============================================================================
# MONITORING
# =============================================================================

variable "log_retention_days" {
  description = "DR Log Analytics workspace data retention in days"
  type        = number
  default     = 30
}
