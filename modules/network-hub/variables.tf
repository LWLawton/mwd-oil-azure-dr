variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "hub_vnet_name"       { type = string }
variable "hub_address_space"   { type = string }
variable "gateway_subnet_cidr" { type = string }
variable "mgmt_subnet_cidr"    { type = string }
variable "shared_subnet_cidr"  { type = string }
variable "tags"                { type = map(string) }

variable "allowed_admin_cidr" {
  description = "CIDR allowed for admin/SSH access. Default 10.0.0.0/8 (RFC1918). Replace with VPN CIDR in production."
  type        = string
  default     = "10.0.0.0/8"
}
