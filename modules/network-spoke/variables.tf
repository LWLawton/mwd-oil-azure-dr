variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "spoke_name"          { type = string }
variable "vnet_address_space"  { type = string }
variable "hub_vnet_id"         { type = string }
variable "hub_vnet_name"       { type = string }
variable "hub_resource_group"  { type = string }
variable "tags"                { type = map(string) }

variable "subnets" {
  description = "Map of subnet names to CIDR blocks"
  type = map(object({
    cidr = string
  }))
}

variable "allowed_admin_cidr" {
  description = "CIDR allowed for SSH/admin access. Default 10.0.0.0/8. Replace with VPN CIDR in production."
  type        = string
  default     = "10.0.0.0/8"
}
