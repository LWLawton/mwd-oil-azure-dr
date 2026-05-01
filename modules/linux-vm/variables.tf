variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "vm_name"             { type = string }
variable "subnet_id"           { type = string }
variable "tags"                { type = map(string) }

variable "vm_size" {
  description = "Azure VM SKU. Default Standard_B2s (~$30/mo). Use Standard_B1s (~$8/mo) for minimal cost."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Linux admin username. Do not use root or admin."
  type        = string
  default     = "mwdadmin"
}

variable "ssh_public_key" {
  description = "SSH public key string for VM access. Set via tfvars — do not hard-code."
  type        = string
  sensitive   = true
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 32
}

variable "data_disk_size_gb" {
  description = "Optional data disk size in GB. Set to 0 to skip data disk."
  type        = number
  default     = 0
}
