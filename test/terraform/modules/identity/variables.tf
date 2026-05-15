variable "resource_group_name" {}
variable "location" {}
variable "name" { default = "aks-workload-identity" }
variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
variable "user_assigned_identity_id" {
  description = "The ID of the user-assigned identity for federated credential (optional)."
  type        = string
  default     = null
}
variable "oidc_issuer_url" {
  description = "The OIDC issuer URL for federated credential (optional)."
  type        = string
  default     = null
}
variable "federated_subject" {
  description = "The subject for federated credential (optional)."
  type        = string
  default     = null
}
