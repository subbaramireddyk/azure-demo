# CRITICAL: Fix Namespace Mismatch Issue

## The Problem

Your **Terraform** federated identity credential is set to:
```
namespace: production
serviceaccount: app-service-account
```

But you probably want to deploy to `voting-app` or `demo` namespace for your assessment demo.

**If these don't match, Workload Identity will fail and pods can't access Key Vault!**

---

## Solution 1: Change Terraform (Recommended for Demo)

Update `Assignment/terraform/main.tf` line 69:

**Change FROM:**
```hcl
federated_subject = "system:serviceaccount:production:app-service-account"
```

**Change TO:**
```hcl
federated_subject = "system:serviceaccount:voting-app:app-service-account"
```

Then run:
```bash
cd Assignment/terraform
terraform apply
```

Now you can deploy to `voting-app` namespace:
```bash
helm install azure-vote . --namespace voting-app --create-namespace
```

---

## Solution 2: Use "production" Namespace (Quick Fix)

Don't change Terraform. Just deploy to `production` namespace:

```bash
helm install azure-vote . --namespace production --create-namespace
```

**Note:** The namespace name "production" is just a label - it doesn't mean actual production environment!

---

## Solution 3: Create Multiple Federated Credentials (Best for Demo)

You can have multiple federated credentials for different namespaces.

Add this to `Assignment/terraform/main.tf` AFTER the existing workload_identity module (around line 71):

```hcl
# Add second federated credential for demo namespace
resource "azurerm_federated_identity_credential" "demo" {
  name                = "aks-federated-credential-demo"
  resource_group_name = azurerm_resource_group.main.name
  parent_id           = module.workload_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:voting-app:app-service-account"
}
```

Run `terraform apply`, then you can deploy to either namespace!

---

## How to Verify Current Configuration

```bash
# Check what federated credentials exist
az identity federated-credential list \
  --identity-name aks-workload-identity \
  --resource-group rg-aks-devsecops-demo \
  --query "[].{name:name, subject:subject}" -o table
```

You should see the subject like:
```
system:serviceaccount:production:app-service-account
```

---

## My Recommendation for Your Assessment

**Use Solution 1** - Change Terraform to use `voting-app` namespace. This is cleaner for a demo and makes it obvious it's not production.

1. Edit `Assignment/terraform/main.tf` line 69
2. Run `terraform apply`
3. Deploy with `helm install azure-vote . --namespace voting-app --create-namespace`

This keeps everything simple and properly labeled for your assessment! 🎯
