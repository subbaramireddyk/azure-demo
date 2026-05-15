# Deploy-Only Pipelines Setup Guide

Two deployment-only pipelines for deploying to AKS (no build stage).

---

## 🎯 Available Pipelines

### Pipeline 1: Helm Deployment (With Key Vault) ⭐

**File**: `azure-pipelines-deploy-only.yml`

**Features**:
- ✅ Deploys using Helm chart
- ✅ Key Vault integration
- ✅ Workload Identity
- ✅ Automatic configuration from Azure
- ✅ Health checks and verification

**Use when**: You want full production setup with Key Vault

---

### Pipeline 2: Simple Deployment (No Helm)

**File**: `azure-pipelines-deploy-simple.yml`

**Features**:
- ✅ Deploys using plain YAML
- ✅ Quick and simple
- ✅ No dependencies
- ❌ No Key Vault

**Use when**: Quick testing or demo without secrets

---

## 📋 Prerequisites

### Before Running Pipelines:

1. **Image in ACR**
   ```bash
   # Build and push image first
   cd Assignment/azure-vote
   az acr login --name acrdevsecopsdemo
   docker build -t acrdevsecopsdemo.azurecr.io/azure-vote:v1 .
   docker push acrdevsecopsdemo.azurecr.io/azure-vote:v1
   ```

2. **Key Vault Secrets** (for Helm pipeline only)
   ```bash
   az keyvault secret set --vault-name kvdevsecopsdemo --name redis-password --value "RedisP@ssw0rd123"
   az keyvault secret set --vault-name kvdevsecopsdemo --name secretKey --value "AppSecret456"
   ```

3. **CSI Secret Store Driver** (for Helm pipeline only)
   ```bash
   helm repo add secrets-store-csi-driver \
     https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
   
   helm install csi-secrets-store \
     secrets-store-csi-driver/secrets-store-csi-driver \
     --namespace kube-system \
     --set syncSecret.enabled=true

   kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml
   ```

---

## 🚀 Setup Steps

### Step 1: Create Service Connection

1. Go to **Azure DevOps** → **Project Settings** → **Service connections**
2. Click **New service connection** → **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Configure:
   - **Subscription**: Your Azure subscription
   - **Resource group**: `rg-aks-devsecops-demo`
   - **Service connection name**: `azure-service-connection`
5. Grant access to all pipelines

### Step 2: Create Pipeline

#### For Helm Deployment:

1. Go to **Pipelines** → **New pipeline**
2. Choose **Azure Repos Git** (or your repo location)
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select path: `/Assignment/azure-pipelines-deploy-only.yml`
6. Click **Continue**
7. **Update variables** in the YAML:
   ```yaml
   variables:
     azureServiceConnection: 'azure-service-connection'  # Your service connection name
     imageTag: 'v1'  # Your image tag
   ```
8. Click **Save** (don't run yet)

#### For Simple Deployment:

Same steps, but use `/Assignment/azure-pipelines-deploy-simple.yml`

---

## ⚙️ Configuration

### Helm Pipeline Variables

Update these in `azure-pipelines-deploy-only.yml`:

```yaml
variables:
  # Azure Resources (from your Terraform)
  resourceGroup: 'rg-aks-devsecops-demo'
  aksCluster: 'aks-devsecops-demo'
  acrName: 'acrdevsecopsdemo'
  keyVaultName: 'kvdevsecopsdemo'

  # Deployment Settings
  namespace: 'voting-app'              # Change if needed
  helmReleaseName: 'azure-vote'
  imageTag: 'v1'                        # ⚠️ CHANGE to your image tag

  # Service Connection
  azureServiceConnection: 'azure-service-connection'  # ⚠️ CHANGE to your connection name
```

### Simple Pipeline Variables

Update these in `azure-pipelines-deploy-simple.yml`:

```yaml
variables:
  resourceGroup: 'rg-aks-devsecops-demo'
  aksCluster: 'aks-devsecops-demo'
  azureServiceConnection: 'azure-service-connection'  # ⚠️ CHANGE to your connection name
```

---

## 🏃 Running the Pipeline

### Option 1: From Azure DevOps UI

1. Go to **Pipelines**
2. Select your pipeline
3. Click **Run pipeline**
4. Click **Run**
5. Watch the deployment progress

### Option 2: Manual Trigger

Since these pipelines have `trigger: none`, they only run when manually triggered.

To enable automatic triggers on code changes:

```yaml
# Change this:
trigger: none

# To this:
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - Assignment/azure-vote-chart-simple/*
```

---

## 📊 Pipeline Stages

### Helm Pipeline Flow:

```
1. Install Helm
   ↓
2. Connect to AKS
   ↓
3. Get Azure Configuration (Tenant ID, Workload Identity)
   ↓
4. Update Helm Dependencies (Redis chart)
   ↓
5. Deploy with Helm
   ↓
6. Verify Deployment
   ↓
7. Get Application URL
   ↓
8. Show Logs
```

### Simple Pipeline Flow:

```
1. Connect to AKS
   ↓
2. Deploy Application (kubectl apply)
   ↓
3. Wait for Pods Ready
   ↓
4. Get Application URL
   ↓
5. Show Logs
```

---

## ✅ Verify Deployment

After pipeline completes:

```bash
# Connect to AKS
az aks get-credentials \
  --resource-group rg-aks-devsecops-demo \
  --name aks-devsecops-demo

# For Helm deployment
kubectl get all -n voting-app
kubectl get svc azure-vote -n voting-app

# For Simple deployment
kubectl get all
kubectl get svc azure-vote-front
```

Open the EXTERNAL-IP in browser to test!

---

## 🔧 Troubleshooting

### Pipeline Fails: "Service connection not found"

**Fix**: Update `azureServiceConnection` variable to match your actual service connection name.

### Pipeline Fails: "Error from server (NotFound): namespaces 'voting-app' not found"

**Solution**: The pipeline creates the namespace automatically. If this fails, create manually:
```bash
kubectl create namespace voting-app
```

### Helm Deployment Fails: "CSI driver not found"

**Fix**: Install CSI Secret Store driver (see Prerequisites section).

### Image Pull Error

**Fix**: Ensure image exists in ACR:
```bash
az acr repository show --name acrdevsecopsdemo --repository azure-vote
```

### Workload Identity Not Working

**Fix**: Check namespace matches Terraform federated credential. See [FIX-NAMESPACE-MISMATCH.md](FIX-NAMESPACE-MISMATCH.md).

---

## 🎯 Which Pipeline Should I Use?

| Scenario | Use Pipeline |
|----------|-------------|
| **Assessment submission** | Helm Pipeline (deploy-only) ⭐ |
| **Testing with Key Vault** | Helm Pipeline |
| **Quick demo** | Simple Pipeline |
| **No secrets needed** | Simple Pipeline |
| **Production-like** | Helm Pipeline |

---

## 🔄 Update Deployment

To redeploy with new image:

### For Helm Pipeline:

1. Update `imageTag` variable in pipeline
2. Run pipeline

### For Simple Pipeline:

1. Update image tag in `azure-vote-all-in-one-redis.yaml`:
   ```yaml
   image: mcr.microsoft.com/azuredocs/azure-vote-front:v2  # Change version
   ```
2. Run pipeline

---

## 🧹 Cleanup

### Remove Helm Deployment:
```bash
helm uninstall azure-vote -n voting-app
kubectl delete namespace voting-app
```

### Remove Simple Deployment:
```bash
kubectl delete -f Assignment/azure-vote-all-in-one-redis.yaml
```

---

## 📝 Pipeline Outputs

Both pipelines provide:

✅ Deployment status  
✅ Pod health checks  
✅ Application URL  
✅ Application logs  
✅ Resource listing  

Perfect for documentation and screenshots! 📸

---

## 🎓 For Your Assessment

**Recommended Approach**:

1. **First**: Run Simple Pipeline to verify connectivity ✅
2. **Then**: Run Helm Pipeline for full solution ⭐
3. **Document**: Take screenshots of both for comparison
4. **Submit**: Helm pipeline as your primary solution

This shows you understand both approaches! 🏆
