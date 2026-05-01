variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "site_name"           { type = string }
variable "spoke_vnet_id"       { type = string }
variable "ot_dmz_subnet_id"    { type = string }
variable "ot_subnet_id"        { type = string }
variable "iot_subnet_id"       { type = string }
variable "it_subnet_cidr"      { type = string }
variable "tags"                { type = map(string) }

variable "allowed_admin_cidr" {
  description = "CIDR allowed for admin/jump host access to OT DMZ. Default 10.0.0.0/8."
  type        = string
  default     = "10.0.0.0/8"
}
