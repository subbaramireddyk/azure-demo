output "workload_identity_client_id" {
  description = "The client ID of the user-assigned managed identity for workloads."
  value       = azurerm_user_assigned_identity.workload.client_id
}

output "workload_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity for workloads."
  value       = azurerm_user_assigned_identity.workload.principal_id
}

output "id" {
  description = "The resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.workload.id
}

output "principal_id" {
  description = "The principal ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.workload.principal_id
}
