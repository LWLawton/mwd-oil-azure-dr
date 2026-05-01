variable "resource_group_name"  { type = string }
variable "location"             { type = string }
variable "environment"          { type = string }
variable "storage_account_name" { type = string }
variable "tags"                 { type = map(string) }

variable "replication_type" {
  description = "Storage replication type: LRS, GRS, RAGRS, ZRS. Use GRS for DR-capable storage."
  type        = string
  default     = "LRS"
}

variable "enable_versioning" {
  description = "Enable blob versioning — recommended for ransomware resilience"
  type        = bool
  default     = true
}

variable "enable_soft_delete" {
  description = "Enable soft delete for blobs and containers"
  type        = bool
  default     = true
}

variable "soft_delete_retention" {
  description = "Soft delete retention in days (7–365)"
  type        = number
  default     = 30
}
