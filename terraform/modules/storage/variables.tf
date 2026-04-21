variable "name" {}
variable "resource_group_name" {}
variable "location" {}
variable "account_tier" { default = "Standard" }
variable "account_replication_type" { default = "LRS" }
variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
