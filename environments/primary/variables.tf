# =============================================================================
# MWD Oil Co. — Primary Environment Variables
# =============================================================================

variable "environment" {
  description = "Environment label — used in resource naming"
  type        = string
  default     = "primary"
}

variable "primary_location" {
  description = "Primary Azure region"
  type        = string
  default     = "southcentralus"
}

# =============================================================================
# NETWORK ADDRESS SPACES
# Each site uses 10.X0.0.0/16 — increments by 10 in the second octet
# =============================================================================

variable "hub_address_space" {
  description = "Primary hub VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "gateway_subnet_cidr" {
  description = "GatewaySubnet CIDR — must be named exactly GatewaySubnet"
  type        = string
  default     = "10.0.0.0/27"
}

variable "mgmt_subnet_cidr" {
  description = "Hub management subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "shared_subnet_cidr" {
  description = "Hub shared services subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "hq_address_space" {
  description = "HQ San Antonio spoke VNet address space"
  type        = string
  default     = "10.10.0.0/16"
}

variable "corpus_christi_address_space" {
  description = "Corpus Christi branch spoke VNet address space"
  type        = string
  default     = "10.20.0.0/16"
}

variable "midland_address_space" {
  description = "Midland/Odessa branch spoke VNet address space"
  type        = string
  default     = "10.30.0.0/16"
}

variable "drillsite_a_address_space" {
  description = "Drill Site A spoke VNet address space"
  type        = string
  default     = "10.40.0.0/16"
}

variable "drillsite_b_address_space" {
  description = "Drill Site B spoke VNet address space"
  type        = string
  default     = "10.50.0.0/16"
}

# =============================================================================
# SUBNET DEFINITIONS
# =============================================================================

variable "hq_subnets" {
  description = "HQ spoke subnet definitions"
  type = map(object({
    cidr = string
  }))
  default = {
    app = {
      cidr = "10.10.1.0/24"
    }
    mgmt = {
      cidr = "10.10.2.0/24"
    }
    data = {
      cidr = "10.10.3.0/24"
    }
    identity = {
      cidr = "10.10.4.0/24"
    }
  }
}

variable "branch_subnets" {
  description = "Branch office spoke subnet definitions (Corpus Christi and Midland share this pattern)"
  type = map(object({
    cidr = string
  }))
  default = {
    app = {
      cidr = "10.20.1.0/24" # Override per-site in tfvars
    }
    mgmt = {
      cidr = "10.20.2.0/24"
    }
  }
}

variable "drillsite_subnets" {
  description = "Drill site spoke subnet definitions — IT, OT DMZ, OT, IoT zones"
  type = map(object({
    cidr = string
  }))
  default = {
    it = {
      cidr = "10.40.1.0/24" # Override per-site in tfvars
    }
    "ot-dmz" = {
      cidr = "10.40.2.0/24"
    }
    ot = {
      cidr = "10.40.3.0/24"
    }
    iot = {
      cidr = "10.40.4.0/24"
    }
  }
}

# =============================================================================
# SECURITY
# =============================================================================

variable "allowed_admin_cidr" {
  description = <<EOT
CIDR range allowed for administrative access (SSH, RDP, management ports).
Default is 10.0.0.0/8 (all RFC1918 private space).
In production, replace with your specific jump host or VPN gateway CIDR.
Do NOT set this to 0.0.0.0/0 — that exposes management ports to the internet.
EOT
  type    = string
  default = "10.0.0.0/8"
}

# =============================================================================
# COMPUTE
# =============================================================================

variable "vm_size" {
  description = <<EOT
Azure VM size for all VMs in this environment.
Default: Standard_B2s (~$30/month) — suitable for lab/demo.
Change to Standard_B1s (~$8/month) for minimal cost.
Do NOT use production-sized SKUs for this lab.
EOT
  type    = string
  default = "Standard_B2s"
}

variable "vm_admin_username" {
  description = "Admin username for Linux VMs — do not use 'root' or 'admin'"
  type        = string
  default     = "mwdadmin"
}

variable "ssh_public_key" {
  description = <<EOT
SSH public key for VM access.
Set via terraform.tfvars (not in source control) or environment variable TF_VAR_ssh_public_key.
Example: "ssh-rsa AAAA... user@host"
EOT
  type      = string
  sensitive = true
}

# =============================================================================
# MONITORING
# =============================================================================

variable "log_retention_days" {
  description = "Log Analytics workspace data retention in days (30 = free tier)"
  type        = number
  default     = 30
}

# =============================================================================
# STORAGE
# =============================================================================

variable "storage_replication_type" {
  description = <<EOT
Storage account replication type.
LRS = Locally Redundant (cheapest, single datacenter)
GRS = Geo-Redundant (recommended for DR, ~2x cost of LRS)
RAGRS = Read-Access Geo-Redundant (GRS + read from secondary)
EOT
  type    = string
  default = "LRS"
}
