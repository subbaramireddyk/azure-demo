variable "tags" {
	description = "Tags to apply to all resources."
	type        = map(string)
	default = {
		environment = "dev"
		managed_by  = "terraform"
		owner       = "devops"
	}
}
variable "resource_group_name" {}
variable "location" {}

# ACR
variable "acr_name" {}
variable "acr_sku" { default = "Basic" }
variable "acr_admin_enabled" { default = false }

# AKS
variable "aks_name" {}
variable "aks_dns_prefix" {}
variable "aks_node_count" { default = 1 }
variable "aks_vm_size" { default = "Standard_DS2_v2" }

# Key Vault
variable "keyvault_name" {}
variable "tenant_id" {}
variable "keyvault_sku" { default = "standard" }

# Storage
variable "storage_name" {}
variable "storage_account_tier" { default = "Standard" }
variable "storage_account_replication_type" { default = "LRS" }
