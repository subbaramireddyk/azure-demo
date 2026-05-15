# Manual Deployment Guide - Azure Vote App

Choose between Helm Chart (with Key Vault) or Simple YAML deployment.

---

## Option A: Deploy with Helm Chart (Recommended - includes Key Vault)

### Prerequisites
```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-devsecops-demo \
  --name aks-devsecops-demo \
  --overwrite-existing

# Install CSI Secret Store Driver
helm repo add secrets-store-csi-driver \
  https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

helm install csi-secrets-store \
  secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system \
  --set syncSecret.enabled=true

kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml
```

### Step 1: Get Terraform Values

```bash
cd Assignment/terraform

# Get Workload Identity Client ID
WORKLOAD_CLIENT_ID=$(terraform output -raw workload_identity_client_id)
echo "Workload Identity Client ID: $WORKLOAD_CLIENT_ID"

# Get Tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "Tenant ID: $TENANT_ID"

# Get ACR Login Server
ACR_SERVER=$(terraform output -raw acr_login_server)
echo "ACR Server: $ACR_SERVER"
```

### Step 2: Create Key Vault Secrets

```bash
# Create secrets
az keyvault secret set --vault-name kvdevsecopsdemo --name redis-password --value "RedisP@ssw0rd123"
az keyvault secret set --vault-name kvdevsecopsdemo --name secretKey --value "AppSecret456"

# Verify
az keyvault secret list --vault-name kvdevsecopsdemo -o table
```

### Step 3: Build and Push Image to ACR

```bash
cd Assignment/azure-vote

# Login to ACR
az acr login --name acrdevsecopsdemo

# Build image
docker build -t acrdevsecopsdemo.azurecr.io/azure-vote:v1 .

# Push to ACR
docker push acrdevsecopsdemo.azurecr.io/azure-vote:v1

# Verify
az acr repository show --name acrdevsecopsdemo --repository azure-vote
```

### Step 4: Update Helm Values

Create `my-values.yaml`:
```yaml
image:
  repository: acrdevsecopsdemo.azurecr.io/azure-vote
  tag: v1

keyVault:
  name: kvdevsecopsdemo
  tenantId: "<PASTE_TENANT_ID>"
  clientId: "<PASTE_WORKLOAD_CLIENT_ID>"

config:
  title: "Azure Voting App - Demo"
  vote1: "Cats"
  vote2: "Dogs"
```

### Step 5: Deploy with Helm

```bash
cd Assignment/azure-vote-chart-simple

# Download Redis dependency
helm dependency update

# Install (use your preferred namespace)
helm install azure-vote . \
  --namespace voting-app \
  --create-namespace \
  --values my-values.yaml

# Watch deployment
kubectl get pods -n voting-app -w
```

### Step 6: Access Application

```bash
# Get LoadBalancer IP (may take 2-3 minutes)
kubectl get svc azure-vote -n voting-app

# Open in browser
# http://<EXTERNAL-IP>
```

### Cleanup Helm Deployment
```bash
helm uninstall azure-vote -n voting-app
kubectl delete namespace voting-app
```

---

## Option B: Deploy with Simple YAML (No Key Vault)

### Quick Deployment

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-devsecops-demo \
  --name aks-devsecops-demo \
  --overwrite-existing

# Deploy
kubectl apply -f Assignment/azure-vote-all-in-one-redis.yaml

# Watch pods
kubectl get pods -w

# Get service IP
kubectl get svc azure-vote-front

# Open in browser: http://<EXTERNAL-IP>
```

### Cleanup Simple YAML Deployment
```bash
kubectl delete -f Assignment/azure-vote-all-in-one-redis.yaml
```

---

## Troubleshooting

### Helm Deployment Issues

**Pods stuck in "ContainerCreating":**
```bash
kubectl describe pod -l app=azure-vote -n voting-app
kubectl logs -l app=csi-secrets-store-provider-azure -n kube-system
```

**Check Key Vault access:**
```bash
kubectl get secretproviderclass -n voting-app
kubectl describe secretproviderclass azure-vote-spc -n voting-app
```

**Verify Workload Identity:**
```bash
kubectl get sa app-service-account -n voting-app -o yaml
```

### Simple YAML Issues

**Image pull errors:**
```bash
kubectl describe pod azure-vote-front-<pod-id>
```

**Service not getting external IP:**
```bash
kubectl get svc azure-vote-front -w
# Wait up to 5 minutes for Azure LoadBalancer provisioning
```

---

## Comparison: Helm vs Simple YAML

| Feature | Helm Chart | Simple YAML |
|---------|-----------|-------------|
| **Key Vault Integration** | ✅ Yes | ❌ No |
| **Workload Identity** | ✅ Yes | ❌ No |
| **Production Ready** | ✅ Yes | ⚠️ Basic |
| **Deployment Time** | ~5 min | ~2 min |
| **Configuration** | values.yaml | Hardcoded |
| **For Assessment** | ✅ Better | ⚠️ OK |

**Recommendation:** Use Helm Chart for your DevSecOps assessment as it demonstrates Key Vault integration and security best practices!
