variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "tenant_id" {}
variable "sku_name" { default = "standard" }
variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
