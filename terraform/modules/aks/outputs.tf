output "oidc_issuer_url" {
  description = "The OIDC issuer URL for AKS Workload Identity federation."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "aks_client_id" {
  description = "The managed identity client ID for the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
}

output "name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "The kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "The raw kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "The kubelet identity for the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}
