# Azure Key Vault Authentication Method Explained

## 🔐 Your Helm Chart Uses: **Workload Identity** (Modern Method)

---

## What's in Your SecretProviderClass

Looking at [secretproviderclass.yaml](azure-vote-chart-simple/templates/secretproviderclass.yaml):

```yaml
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"          # ❌ NOT using Pod Identity
    useVMManagedIdentity: "false"    # ❌ NOT using VM Managed Identity
    clientID: {{ .Values.keyVault.clientId }}  # ✅ Using Workload Identity Client ID
    keyvaultName: {{ .Values.keyVault.name }}
    tenantId: {{ .Values.keyVault.tenantId }}
```

---

## 🎯 Authentication Method: **Workload Identity** ⭐

### How It Works:

```
┌─────────────────────────────────────────────────────────┐
│  Pod with ServiceAccount (app-service-account)          │
│  Label: azure.workload.identity/use: "true"            │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│  Azure AD Workload Identity Federation                  │
│  (OpenID Connect - OIDC)                                │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│  Managed Identity: aks-workload-identity                │
│  Federated Credential: Links K8s SA to Azure Identity   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│  Azure Key Vault                                        │
│  RBAC: "Key Vault Secrets User" role assigned          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Authentication Flow (Step by Step)

### 1. Pod Starts with ServiceAccount

```yaml
# deployment.yaml
spec:
  serviceAccountName: app-service-account  # ✅ Pod uses this SA
  labels:
    azure.workload.identity/use: "true"   # ✅ Enables Workload Identity
```

### 2. ServiceAccount Has Client ID Annotation

```yaml
# serviceaccount.yaml
metadata:
  annotations:
    azure.workload.identity/client-id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

This tells Azure: "This Kubernetes ServiceAccount maps to this Azure Managed Identity"

### 3. Workload Identity Webhook Injects Token

When the pod starts, the **Workload Identity webhook** automatically:
- Injects environment variables
- Mounts a service account token
- Token is signed by AKS's OIDC issuer

### 4. CSI Driver Authenticates to Key Vault

```yaml
# secretproviderclass.yaml
parameters:
  clientID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Managed Identity Client ID
  tenantId: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

The CSI driver:
1. Reads the injected service account token
2. Exchanges it for an Azure AD access token
3. Uses the token to authenticate to Key Vault
4. Fetches secrets: `redis-password`, `secretKey`

### 5. Secrets Mounted to Pod

```yaml
# deployment.yaml
volumeMounts:
  - name: secrets-store
    mountPath: "/mnt/secrets-store"
```

Secrets are available at: `/mnt/secrets-store/redis-password`

---

## 🆚 Comparison: Authentication Methods

| Method | Used? | How It Works | Security |
|--------|-------|--------------|----------|
| **Workload Identity** | ✅ **YES** (Your chart) | OIDC federation, no secrets | ⭐⭐⭐⭐⭐ Best |
| **Pod Identity** | ❌ No | Deprecated, older method | ⭐⭐⭐ Good |
| **VM Managed Identity** | ❌ No | Uses node's identity | ⭐⭐ OK |
| **Service Principal** | ❌ No | Username/password | ⭐ Not recommended |

---

## ✅ Why Workload Identity is Best

### Advantages:

1. **No Secrets** ✅
   - No passwords, keys, or certificates stored anywhere
   - Nothing to rotate or expire

2. **Pod-Level Identity** ✅
   - Each pod can have different identity
   - Granular access control

3. **Industry Standard** ✅
   - Uses OIDC (OpenID Connect)
   - Same pattern as AWS IRSA, GCP Workload Identity

4. **Azure Recommended** ✅
   - Microsoft's recommended approach
   - Future-proof

5. **Least Privilege** ✅
   - Only specific pods get specific permissions
   - Not all pods on the node

---

## 🔧 How Your Terraform Configured This

In your Terraform ([main.tf](terraform/main.tf)):

### 1. Created Managed Identity

```hcl
module "workload_identity" {
  source = "./modules/identity"
  name   = "aks-workload-identity"
  # Creates: User Assigned Managed Identity
}
```

### 2. Created Federated Credential

```hcl
# Links Kubernetes ServiceAccount to Azure Identity
oidc_issuer_url   = module.aks.oidc_issuer_url
federated_subject = "system:serviceaccount:production:app-service-account"
#                    ^            ^           ^
#                    |            |           +-- ServiceAccount name
#                    |            +-------------- Namespace
#                    +--------------------------- Kubernetes system identifier
```

### 3. Granted Key Vault Access

```hcl
resource "azurerm_role_assignment" "workload_kv_secrets_user" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}
```

---

## 🔑 Required Configuration

For Workload Identity to work, you need:

### 1. AKS Must Have:
- ✅ OIDC Issuer enabled (Terraform did this)
- ✅ Workload Identity enabled (Terraform did this)

### 2. Managed Identity Must Have:
- ✅ Federated credential configured (Terraform did this)
- ✅ Key Vault RBAC permissions (Terraform did this)

### 3. Kubernetes Resources Must Have:
- ✅ ServiceAccount with client ID annotation (Helm chart has this)
- ✅ Pod with Workload Identity label (Helm chart has this)
- ✅ SecretProviderClass with client ID (Helm chart has this)

### 4. Namespace Must Match:
- ⚠️ Terraform: `system:serviceaccount:production:app-service-account`
- ⚠️ Your deployment: Must use namespace `production` OR update Terraform

---

## 🎓 What You Need to Provide

Only **2 values** in [values.yaml](azure-vote-chart-simple/values.yaml):

```yaml
keyVault:
  clientId: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Managed Identity Client ID
  tenantId: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Azure AD Tenant ID
```

**Get these**:
```bash
# Client ID (from Terraform)
terraform output -raw workload_identity_client_id

# Tenant ID (from Azure)
az account show --query tenantId -o tsv
```

---

## 🔍 Verify Workload Identity is Working

After deployment:

### 1. Check ServiceAccount
```bash
kubectl get sa app-service-account -n voting-app -o yaml

# Should show:
# annotations:
#   azure.workload.identity/client-id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 2. Check Pod Labels
```bash
kubectl get pod -n voting-app -l app=azure-vote -o yaml

# Should show:
# labels:
#   azure.workload.identity/use: "true"
```

### 3. Check Injected Environment Variables
```bash
kubectl exec -n voting-app <pod-name> -- env | grep AZURE

# Should show:
# AZURE_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# AZURE_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# AZURE_FEDERATED_TOKEN_FILE=/var/run/secrets/azure/tokens/azure-identity-token
```

### 4. Check Token File
```bash
kubectl exec -n voting-app <pod-name> -- cat /var/run/secrets/azure/tokens/azure-identity-token

# Should show: JWT token (long string)
```

### 5. Check Secrets Mounted
```bash
kubectl exec -n voting-app <pod-name> -- ls -la /mnt/secrets-store/

# Should show:
# redis-password
# secretKey
```

### 6. Check Secret Values
```bash
kubectl exec -n voting-app <pod-name> -- cat /mnt/secrets-store/redis-password

# Should show: RedisP@ssw0rd123
```

---

## 🚨 Common Issues

### Issue: "failed to get objectType:secret, objectName:redis-password"

**Cause**: Workload Identity not authenticating

**Check**:
```bash
# 1. Verify federated credential exists
az identity federated-credential list \
  --identity-name aks-workload-identity \
  --resource-group rg-aks-devsecops-demo

# 2. Check namespace matches
# If Terraform says "production" but you deploy to "voting-app" = FAIL
```

**Fix**: See [FIX-NAMESPACE-MISMATCH.md](FIX-NAMESPACE-MISMATCH.md)

### Issue: "No clientID or AADClientID found"

**Cause**: Missing client ID in values.yaml or SecretProviderClass

**Fix**:
```bash
# Get client ID
terraform output -raw workload_identity_client_id

# Update values.yaml
keyVault:
  clientId: "<paste-value-here>"
```

---

## 📊 Summary

| Question | Answer |
|----------|--------|
| **Authentication Method** | ✅ Workload Identity (OIDC) |
| **Uses Passwords/Secrets?** | ❌ No - Token-based |
| **Security Level** | ⭐⭐⭐⭐⭐ Highest |
| **Configured By** | Terraform (infrastructure) + Helm (application) |
| **Token Type** | Service Account Token → Azure AD Access Token |
| **Token Location** | `/var/run/secrets/azure/tokens/azure-identity-token` |
| **Permission Method** | Azure RBAC on Key Vault |
| **Role Assigned** | "Key Vault Secrets User" |

---

## 🎯 For Your Assessment Documentation

Explain it like this:

> "The application uses **Azure AD Workload Identity** for authentication. This is a passwordless authentication method that uses OpenID Connect (OIDC) federation to establish trust between Kubernetes and Azure AD. 
> 
> The Kubernetes ServiceAccount is federated with an Azure Managed Identity, which has 'Key Vault Secrets User' RBAC permission. When the pod starts, the Workload Identity webhook injects a service account token. The CSI Secret Store driver exchanges this token for an Azure AD access token and uses it to authenticate to Key Vault.
>
> This approach provides pod-level identity without storing any credentials in the cluster, following the principle of least privilege and Azure's security best practices."

Perfect for your assessment! 🎓
