variable "name" {}
variable "resource_group_name" {}
variable "location" {}
variable "sku" { default = "Basic" }
variable "admin_enabled" { default = false }
variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
