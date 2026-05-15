# Deploy Azure Vote App Using Terraform Resources

## ⚠️ IMPORTANT: Namespace MUST be "production"

Your Terraform federated identity is configured for:
- **Namespace**: `production` 
- **ServiceAccount**: `app-service-account`

**Do NOT change these or Workload Identity will fail!**

---

## Step 1: Get Terraform Values

```bash
cd Assignment/terraform

# Get Workload Identity Client ID (CRITICAL!)
terraform output -raw workload_identity_client_id

# Get Tenant ID
az account show --query tenantId -o tsv

# Get ACR Login Server (already in values.yaml)
terraform output -raw acr_login_server
# Should be: acrdevsecopsdemo.azurecr.io
```

---

## Step 2: Update values.yaml

Edit `values.yaml` and fill in these two values:

```yaml
keyVault:
  name: kvdevsecopsdemo
  tenantId: "<paste-tenant-id-here>"           # From: az account show
  clientId: "<paste-workload-identity-client-id>"  # From: terraform output
```

---

## Step 3: Create Secrets in Key Vault

```bash
# Create redis password
az keyvault secret set \
  --vault-name kvdevsecopsdemo \
  --name redis-password \
  --value "RedisP@ssw0rd123"

# Create app secret key
az keyvault secret set \
  --vault-name kvdevsecopsdemo \
  --name secretKey \
  --value "MyAppSecretKey456"

# Verify
az keyvault secret list --vault-name kvdevsecopsdemo -o table
```

---

## Step 4: Build and Push Docker Image to ACR

```bash
cd Assignment/azure-vote

# Login to ACR
az acr login --name acrdevsecopsdemo

# Build image
docker build -t acrdevsecopsdemo.azurecr.io/azure-vote:v1 .

# Push to ACR
docker push acrdevsecopsdemo.azurecr.io/azure-vote:v1
```

---

## Step 5: Get AKS Credentials

```bash
# Get credentials from Terraform
az aks get-credentials \
  --resource-group rg-aks-devsecops-demo \
  --name aks-devsecops-demo \
  --overwrite-existing

# Verify connection
kubectl get nodes
```

---

## Step 6: Install CSI Secret Store Driver

```bash
# Add Helm repo
helm repo add secrets-store-csi-driver \
  https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

# Install CSI driver
helm install csi-secrets-store \
  secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system \
  --set syncSecret.enabled=true

# Install Azure Provider
kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod \
  -l app=secrets-store-csi-driver \
  -n kube-system --timeout=120s
```

---

## Step 7: Deploy Helm Chart

```bash
cd Assignment/azure-vote-chart-simple

# Download Redis dependency
helm dependency update

# Install to "production" namespace (MUST match Terraform!)
helm install azure-vote . \
  --namespace production \
  --create-namespace

# Check deployment status
kubectl get all -n production
kubectl get secretproviderclass -n production
```

---

## Step 8: Verify Deployment

```bash
# Check pods are running
kubectl get pods -n production

# Check if secrets are mounted
kubectl describe pod -l app=azure-vote -n production | grep -A 5 "Mounts:"

# Check service account
kubectl get sa app-service-account -n production -o yaml

# Get LoadBalancer IP (may take 2-3 minutes)
kubectl get svc azure-vote -n production -w
```

Once LoadBalancer has an EXTERNAL-IP, open it in browser:
```
http://<EXTERNAL-IP>
```

---

## Troubleshooting

### If pods show "FailedMount" for secrets:

```bash
# Check SecretProviderClass
kubectl describe secretproviderclass azure-vote-spc -n production

# Check CSI driver logs
kubectl logs -l app=csi-secrets-store-provider-azure -n kube-system

# Verify Key Vault access
az keyvault show --name kvdevsecopsdemo --query properties.enableRbacAuthorization
```

### If Workload Identity fails:

```bash
# Verify federated credential exists
az identity federated-credential list \
  --identity-name aks-workload-identity \
  --resource-group rg-aks-devsecops-demo

# Should show:
# - issuer: <AKS OIDC URL>
# - subject: system:serviceaccount:production:app-service-account
```

### View application logs:

```bash
kubectl logs -l app=azure-vote -n production -f
```

---

## Cleanup

```bash
# Uninstall Helm release
helm uninstall azure-vote -n production

# Delete namespace
kubectl delete namespace production
```

---

## Quick Reference

| Resource | Value |
|----------|-------|
| **Namespace** | `production` (DO NOT CHANGE!) |
| **ServiceAccount** | `app-service-account` (DO NOT CHANGE!) |
| **ACR** | `acrdevsecopsdemo.azurecr.io` |
| **Key Vault** | `kvdevsecopsdemo` |
| **AKS Cluster** | `aks-devsecops-demo` |
| **Resource Group** | `rg-aks-devsecops-demo` |
| **Image** | `acrdevsecopsdemo.azurecr.io/azure-vote:v1` |
