# Azure DevOps Pipeline Setup Guide

## Prerequisites

1. Azure DevOps organization and project
2. Terraform resources already provisioned
3. Service connections configured

---

## Step 1: Create Service Connections in Azure DevOps

### A. Azure Resource Manager Service Connection

1. Go to **Project Settings** → **Service connections**
2. Click **New service connection** → **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Configure:
   - **Subscription**: Your Azure subscription
   - **Resource group**: `rg-aks-devsecops-demo`
   - **Service connection name**: `azure-service-connection`
5. Grant access to all pipelines

### B. Azure Container Registry Service Connection

1. Click **New service connection** → **Docker Registry**
2. Choose **Azure Container Registry**
3. Configure:
   - **Subscription**: Your Azure subscription
   - **Azure container registry**: `acrdevsecopsdemo`
   - **Service connection name**: `acr-service-connection`
4. Click **Save**

### C. Kubernetes Service Connection

1. Click **New service connection** → **Kubernetes**
2. Choose **Azure Subscription**
3. Configure:
   - **Subscription**: Your Azure subscription
   - **Cluster**: `aks-devsecops-demo`
   - **Namespace**: `voting-app`
   - **Service connection name**: `aks-service-connection`
4. Click **Save**

---

## Step 2: Create Pipeline Variables

Go to **Pipelines** → **Library** → **Variable groups** → **+ Variable group**

**Variable group name**: `azure-vote-config`

Add these variables:

| Variable Name | Value | Secret? |
|---------------|-------|---------|
| `azureServiceConnection` | `azure-service-connection` | No |
| `acrServiceConnection` | `acr-service-connection` | No |
| `kubernetesServiceConnection` | `aks-service-connection` | No |

---

## Step 3: Prepare Key Vault Secrets

```bash
# Create secrets in Key Vault
az keyvault secret set --vault-name kvdevsecopsdemo --name redis-password --value "RedisP@ssw0rd123"
az keyvault secret set --vault-name kvdevsecopsdemo --name secretKey --value "AppSecret456"

# Verify
az keyvault secret list --vault-name kvdevsecopsdemo -o table
```

---

## Step 4: Install CSI Secret Store Driver (One-time)

Run this manually or create a separate pipeline:

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-devsecops-demo \
  --name aks-devsecops-demo

# Install CSI driver
helm repo add secrets-store-csi-driver \
  https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

helm install csi-secrets-store \
  secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system \
  --set syncSecret.enabled=true

# Install Azure provider
kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

# Verify
kubectl get pods -n kube-system -l app=secrets-store-csi-driver
```

---

## Step 5: Create Azure Pipeline

### Option A: Using YAML Pipeline (Recommended)

1. Go to **Pipelines** → **New pipeline**
2. Choose **Azure Repos Git** (or your repo location)
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select path: `/Assignment/azure-pipelines-helm-deploy.yml`
6. Click **Continue**
7. **Update these variables** in the YAML:
   ```yaml
   variables:
     azureServiceConnection: 'azure-service-connection'
     acrServiceConnection: 'acr-service-connection'
     kubernetesServiceConnection: 'aks-service-connection'
   ```
8. Click **Save and run**

### Option B: Simple YAML Pipeline (No Key Vault)

If you want to skip Key Vault integration for quick demo:

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  resourceGroup: 'rg-aks-devsecops-demo'
  aksCluster: 'aks-devsecops-demo'

steps:
  - task: AzureCLI@2
    displayName: 'Get AKS Credentials'
    inputs:
      azureSubscription: 'azure-service-connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az aks get-credentials \
          --resource-group $(resourceGroup) \
          --name $(aksCluster) \
          --overwrite-existing

  - task: Kubernetes@1
    displayName: 'Deploy to AKS'
    inputs:
      connectionType: 'Azure Resource Manager'
      azureSubscriptionEndpoint: 'azure-service-connection'
      azureResourceGroup: '$(resourceGroup)'
      kubernetesCluster: '$(aksCluster)'
      command: 'apply'
      arguments: '-f Assignment/azure-vote-all-in-one-redis.yaml'

  - task: Kubernetes@1
    displayName: 'Get Service IP'
    inputs:
      connectionType: 'Azure Resource Manager'
      azureSubscriptionEndpoint: 'azure-service-connection'
      azureResourceGroup: '$(resourceGroup)'
      kubernetesCluster: '$(aksCluster)'
      command: 'get'
      arguments: 'svc azure-vote-front'
```

---

## Step 6: Run the Pipeline

1. Click **Run pipeline**
2. Watch the stages:
   - **Build**: Builds Docker image and pushes to ACR
   - **Deploy**: Deploys to AKS using Helm
3. Check the deployment:
   ```bash
   kubectl get all -n voting-app
   kubectl get svc azure-vote -n voting-app
   ```

---

## Step 7: Create Release Pipeline (Classic UI - Alternative)

If you prefer Classic Release Pipelines:

### Build Pipeline (CI)

1. **New pipeline** → **Use the classic editor**
2. Add tasks:
   - **Docker** → Build an image
   - **Docker** → Push an image to ACR
   - **Publish build artifacts** → Publish Helm chart

### Release Pipeline (CD)

1. **Releases** → **New pipeline**
2. Add artifact: Select your build pipeline
3. Add stage: **Deploy to AKS**
4. Add tasks:
   - **Helm tool installer**
   - **Azure CLI** → Get AKS credentials
   - **Helm deploy** → Deploy chart
   - **Kubernetes** → Get service info

---

## Troubleshooting

### Pipeline fails at "Get AKS Credentials"

**Issue**: Service principal doesn't have access to AKS.

**Fix**:
```bash
# Get service principal ID
SP_ID=$(az ad sp list --display-name "azure-service-connection" --query "[0].id" -o tsv)

# Grant access to AKS
az role assignment create \
  --assignee $SP_ID \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-aks-devsecops-demo/providers/Microsoft.ContainerService/managedClusters/aks-devsecops-demo
```

### Helm deployment fails with "connection refused"

**Issue**: Kubernetes service connection not configured correctly.

**Fix**: Recreate the Kubernetes service connection using AKS credentials method.

### Image pull errors in AKS

**Issue**: AKS can't pull from ACR.

**Fix**: This should be handled by Terraform role assignment, but verify:
```bash
az aks update \
  --name aks-devsecops-demo \
  --resource-group rg-aks-devsecops-demo \
  --attach-acr acrdevsecopsdemo
```

### Workload Identity not working

**Issue**: Federated credential namespace mismatch.

**Fix**: Make sure Terraform federated credential matches the namespace you're deploying to:
```hcl
# In terraform/main.tf
federated_subject = "system:serviceaccount:voting-app:app-service-account"
```

Then run `terraform apply`.

---

## Pipeline Features for Assessment

This pipeline demonstrates:

✅ **CI/CD**: Automated build and deployment  
✅ **DevSecOps**: Image security scanning with Trivy  
✅ **ACR Integration**: Push/pull from Azure Container Registry  
✅ **AKS Deployment**: Kubernetes deployment automation  
✅ **Helm**: Package management for Kubernetes  
✅ **Key Vault**: Secrets management (via Workload Identity)  
✅ **Infrastructure as Code**: Helm charts  
✅ **Security**: RBAC, Workload Identity, image scanning  

Perfect for your hands-on assessment! 🎯
