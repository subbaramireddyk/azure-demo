# Resource Group and Location
resource_group_name = "rg-aks-devsecops-demo"
location            = "southindia"

# ACR - name must be globally unique and 5-50 alphanumeric characters
acr_name            = "acrdevsecopsdemo"
acr_sku             = "Basic"
acr_admin_enabled   = false

# AKS Cluster
aks_name            = "aks-devsecops-demo"
aks_dns_prefix      = "aksdevsecopsdemo"
aks_node_count      = 1
aks_vm_size         = "Standard_D2s_v3"

# Key Vault - name must be globally unique and 3-24 alphanumeric characters
keyvault_name       = "kvdevsecopsdemo"
tenant_id           = "<your-tenant-id>"  # Get this by running: az account show --query tenantId -o tsv
keyvault_sku        = "standard"

# Storage Account - name must be globally unique, 3-24 lowercase letters and numbers
storage_name                    = "stdevsecopsdemo"
storage_account_tier            = "Standard"
storage_account_replication_type = "LRS"
