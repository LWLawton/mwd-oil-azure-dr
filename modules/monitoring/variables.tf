variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "workspace_name"      { type = string }
variable "tags"                { type = map(string) }

variable "log_retention_days" {
  description = "Data retention in days. 30 = free tier. Max 730 days."
  type        = number
  default     = 30
}
