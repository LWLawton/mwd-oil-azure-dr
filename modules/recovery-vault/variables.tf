variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "vault_name"          { type = string }
variable "tags"                { type = map(string) }

variable "soft_delete_enabled" {
  description = "Enable soft delete on the vault. Strongly recommended — prevents accidental/ransomware deletion of backups."
  type        = bool
  default     = true
}
