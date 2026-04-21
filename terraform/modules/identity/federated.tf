resource "azurerm_federated_identity_credential" "workload" {
  count               = var.oidc_issuer_url != null && var.federated_subject != null ? 1 : 0
  name                = "aks-federated-credential"
  resource_group_name = var.resource_group_name
  parent_id           = var.user_assigned_identity_id != null ? var.user_assigned_identity_id : azurerm_user_assigned_identity.workload.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = var.federated_subject
}
