resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.34.0"
  tags                = var.tags

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    min_count  = var.min_count
    max_count  = var.max_count
    enable_auto_scaling = true
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Key Vault CSI driver and secret rotation
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Enable OIDC and Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
  }
}
