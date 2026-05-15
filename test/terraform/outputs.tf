output "workload_identity_client_id" {
  description = "The client ID of the user-assigned managed identity for workloads."
  value       = module.workload_identity.workload_identity_client_id
}

output "workload_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity for workloads."
  value       = module.workload_identity.workload_identity_principal_id
}
output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL for AKS Workload Identity federation."
  value       = module.aks.oidc_issuer_url
}

output "aks_managed_identity_client_id" {
  description = "The managed identity client ID for the AKS cluster."
  value       = module.aks.aks_client_id
}
output "aks_cluster_name" {
  value = module.aks.name
}

output "aks_resource_group" {
  value = azurerm_resource_group.main.name
}

output "aks_kube_config" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "acr_resource_id" {
  value = module.acr.id
}

output "keyvault_uri" {
  value = module.keyvault.vault_uri
}

output "keyvault_id" {
  value = module.keyvault.id
}

output "storage_account_name" {
  value = module.storage.name
}

output "storage_account_id" {
  value = module.storage.id
}
