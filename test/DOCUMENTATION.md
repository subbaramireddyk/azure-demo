# Azure DevSecOps Assessment - Azure Vote Application Deployment

**Candidate**: [Your Name]  
**Date**: April 21, 2026  
**Assessment Duration**: 48 hours  

[[_TOC_]]

---

## 1. Architecture Overview

### Solution Architecture Diagram
::: tip Screenshot Required
Create/draw architecture diagram showing:
- AKS Cluster
- Azure Container Registry
- Azure Key Vault
- Azure Storage Account
- Azure DevOps Pipeline
- Workload Identity flow

**Paste image here:**
:::

![Architecture Diagram](/.attachments/architecture-diagram.png)

### Components Used
| Component | Resource Name | Purpose |
|-----------|---------------|---------|
| AKS Cluster | aks-devsecops-demo | Kubernetes runtime environment |
| Container Registry | acrdevsecopsdemo | Docker image storage |
| Key Vault | kvdevsecopsdemo | Secrets management |
| Storage Account | stdevsecopsdemo | Static assets & data persistence |
| Service Connection | aks-service-connection | Azure DevOps to AKS authentication |

---

## 2. Infrastructure Setup

### Terraform Deployment
**Infrastructure as Code** was used to provision all Azure resources.

> **Screenshot 1**: Show Terraform files structure
> - Command: `tree terraform/` or `ls -R terraform/`
> - Capture: File listing showing main.tf, variables.tf, outputs.tf

> **Screenshot 2**: Terraform apply output
> - Command: `terraform apply`
> - Capture: Final output showing all resources created successfully

> **Screenshot 3**: Azure Portal - Resource Group
> - Navigate: Azure Portal → Resource Groups → [your-rg-name]
> - Capture: All provisioned resources in the resource group

**Key Resources Provisioned:**
- ✅ AKS Cluster with Workload Identity enabled
- ✅ Azure Container Registry with admin enabled
- ✅ Azure Key Vault with access policies
- ✅ Azure Storage Account
- ✅ Federated Identity Credentials for workload authentication

---

## 3. Container Registry

### Docker Image Build & Push

> **Screenshot 4**: Docker build command
> - Command: `docker build -t acrdevsecopsdemo.azurecr.io/azure-vote:latest .`
> - Capture: Terminal showing successful build

> **Screenshot 5**: ACR login and push
> - Commands:
>   ```bash
>   az acr login --name acrdevsecopsdemo
>   docker push acrdevsecopsdemo.azurecr.io/azure-vote:latest
>   ```
> - Capture: Successful push output

> **Screenshot 6**: Azure Portal - ACR Repositories
> - Navigate: Azure Portal → Container Registry → acrdevsecopsdemo → Repositories
> - Capture: azure-vote repository with latest tag

---

## 4. Azure Key Vault Integration

### Secrets Configuration

> **Screenshot 7**: Key Vault secrets creation
> - Commands:
>   ```bash
>   az keyvault secret set --vault-name kvdevsecopsdemo --name redis-password --value "RedisP@ssw0rd123"
>   az keyvault secret set --vault-name kvdevsecopsdemo --name secretKey --value "YourSecretKey123"
>   ```
> - Capture: Terminal output showing secrets created

> **Screenshot 8**: Azure Portal - Key Vault Secrets
> - Navigate: Azure Portal → Key Vault → kvdevsecopsdemo → Secrets
> - Capture: List showing redis-password and secretKey

> **Screenshot 9**: Workload Identity Configuration
> - Navigate: Azure Portal → Key Vault → Access configuration
> - Capture: Workload Identity (Managed Identity) shown in access policies

### Secrets Access from Pods

> **Screenshot 10**: SecretProviderClass YAML
> - File: `Assignment/azure-vote-chart-simple/templates/secretproviderclass.yaml`
> - Capture: Code showing Key Vault integration configuration

> **Screenshot 11**: Deployed SecretProviderClass
> - Command: `kubectl get secretproviderclass -n production`
> - Capture: azure-vote-spc resource listed

> **Screenshot 12**: Kubernetes Secret Created by CSI Driver
> - Command: `kubectl get secret azure-vote-secrets -n production -o yaml`
> - Capture: Secret with redis-password and secret-key keys (base64 encoded)

---

## 5. Helm Chart Implementation

### Chart Structure

> **Screenshot 13**: Helm chart directory structure
> - Command: `tree Assignment/azure-vote-chart-simple/`
> - Capture: Complete chart structure showing:
>   - Chart.yaml
>   - values.yaml
>   - templates/

> **Screenshot 14**: Chart.yaml with Redis dependency
> - File: `Assignment/azure-vote-chart-simple/Chart.yaml`
> - Capture: Code showing Bitnami Redis dependency

> **Screenshot 15**: values.yaml configuration
> - File: `Assignment/azure-vote-chart-simple/values.yaml`
> - Capture: Key sections - image, service, keyVault, redis config

### Helm Dependency Management

> **Screenshot 16**: Helm dependency update
> - Command: `helm dependency update Assignment/azure-vote-chart-simple/`
> - Capture: Output showing Redis chart downloaded

> **Screenshot 17**: Chart dependencies downloaded
> - Command: `ls -la Assignment/azure-vote-chart-simple/charts/`
> - Capture: redis-19.0.2.tgz file present

---

## 6. Azure Storage Integration

### Storage Container Setup

> **Screenshot 18**: Storage container creation
> - Command:
>   ```bash
>   az storage container create --name vote-assets --account-name stdevsecopsdemo --public-access blob
>   ```
> - Capture: Successful creation message

> **Screenshot 19**: Logo upload to Storage
> - Command:
>   ```bash
>   az storage blob upload --account-name stdevsecopsdemo --container-name vote-assets --name logo.png --file logo.png
>   ```
> - Capture: Upload success with blob URL

> **Screenshot 20**: Azure Portal - Storage Container
> - Navigate: Azure Portal → Storage Account → stdevsecopsdemo → Containers → vote-assets
> - Capture: logo.png blob listed

> **Screenshot 21**: Public blob URL accessible
> - Command: `curl -I https://stdevsecopsdemo.blob.core.windows.net/vote-assets/logo.png`
> - Capture: HTTP 200 OK response with content-type: image/png

### Application Integration

> **Screenshot 22**: HTML code using Storage URL
> - File: `Assignment/azure-vote/azure-vote/templates/index.html`
> - Capture: `<img>` tag with Storage blob URL

---

## 7. CI/CD Pipeline

### Azure DevOps Setup

> **Screenshot 23**: Pipeline variables configuration
> - Navigate: Azure DevOps → Pipelines → [Your Pipeline] → Edit → Variables
> - Capture: tenantId and clientId variables configured

> **Screenshot 24**: Kubernetes Service Connection
> - Navigate: Azure DevOps → Project Settings → Service Connections
> - Capture: aks-service-connection details showing:
>   - Connection type: Kubernetes
>   - Namespace: production
>   - Status: Ready

### Pipeline Configuration

> **Screenshot 25**: Pipeline YAML file
> - File: `Assignment/azure-pipeline-simple-deploy.yml`
> - Capture: Complete pipeline showing:
>   - Helm dependency update step
>   - HelmDeploy task
>   - Application reachability test

> **Screenshot 26**: Pipeline run - Overview
> - Navigate: Azure DevOps → Pipelines → Runs → [Latest Run]
> - Capture: Successful pipeline run with all stages green

> **Screenshot 27**: Pipeline run - Helm deploy step
> - Navigate: Pipeline run → Deploy stage → DeployApp job → "Deploy to AKS" step
> - Capture: Helm upgrade command output showing:
>   - Release: azure-vote
>   - Namespace: production
>   - Status: deployed

> **Screenshot 28**: Pipeline run - Application reachability test
> - Navigate: Same run → "Test Application is Reachable" step
> - Capture: Output showing:
>   - External IP address
>   - "✅ Application is REACHABLE!" message

---

## 8. Application Deployment

### Kubernetes Resources

> **Screenshot 29**: All deployed resources
> - Command: `kubectl get all -n production`
> - Capture: Pods, Services, Deployments, StatefulSets (Redis)

> **Screenshot 30**: Azure Vote deployment details
> - Command: `kubectl describe deployment azure-vote -n production`
> - Capture: Showing:
>   - Replicas: 2/2
>   - Image: acrdevsecopsdemo.azurecr.io/azure-vote:latest
>   - ServiceAccount: app-service-account
>   - Conditions: Available

> **Screenshot 31**: Azure Vote pods running
> - Command: `kubectl get pods -n production -l app=azure-vote`
> - Capture: 2 pods in Running state

> **Screenshot 32**: Pod describe showing Workload Identity
> - Command: `kubectl describe pod [azure-vote-pod] -n production`
> - Capture: Labels section showing:
>   - azure.workload.identity/use: "true"
>   - Environment variables from secrets

> **Screenshot 33**: Redis StatefulSet running
> - Command: `kubectl get statefulset -n production`
> - Capture: azure-vote-redis-master with 1/1 ready

> **Screenshot 34**: Service with LoadBalancer IP
> - Command: `kubectl get svc azure-vote -n production`
> - Capture: Service type LoadBalancer with EXTERNAL-IP assigned

---

## 9. Testing & Verification

### Application Functionality

> **Screenshot 35**: Application homepage - Browser
> - URL: http://[EXTERNAL-IP]
> - Capture: Voting application showing:
>   - Title: "Azure Vote App"
>   - Logo from Storage (right-click → Inspect to show blob URL)
>   - Cats and Dogs buttons
>   - Current vote counts

> **Screenshot 36**: Browser DevTools - Network tab
> - Action: Refresh page with DevTools open (F12 → Network)
> - Capture: Network request showing logo loaded from:
>   - stdevsecopsdemo.blob.core.windows.net/vote-assets/logo.png
>   - Status: 200 OK

> **Screenshot 37**: Vote functionality test
> - Action: Click "Cats" button multiple times
> - Capture: Vote count incrementing (proving Redis connection works)

> **Screenshot 38**: Reset functionality
> - Action: Click "Reset" button
> - Capture: Votes reset to 0 (proving Redis write operations work)

### Security Verification

> **Screenshot 39**: Pod environment variables
> - Command: `kubectl exec -n production [azure-vote-pod] -- env | grep -E 'REDIS|AZURE'`
> - Capture: Environment variables showing:
>   - REDIS=azure-vote-redis-master
>   - REDIS_PWD=[value from secret]
>   - AZURE_STORAGE_ACCOUNT=stdevsecopsdemo (if added)

> **Screenshot 40**: Secret mounted in pod
> - Command: `kubectl exec -n production [azure-vote-pod] -- ls -la /mnt/secrets-store/`
> - Capture: redis-password and secretKey files mounted from Key Vault

> **Screenshot 41**: Verify secret content matches Key Vault
> - Command: `kubectl exec -n production [azure-vote-pod] -- cat /mnt/secrets-store/redis-password`
> - Capture: Password value (compare with Key Vault secret)

### Workload Identity Verification

> **Screenshot 42**: ServiceAccount with Workload Identity annotation
> - Command: `kubectl get sa app-service-account -n production -o yaml`
> - Capture: Annotation showing azure.workload.identity/client-id

> **Screenshot 43**: Federated Identity Credential in Azure
> - Navigate: Azure Portal → Managed Identity → [workload-identity-name] → Federated credentials
> - Capture: Credential showing:
>   - Issuer: AKS OIDC issuer URL
>   - Subject: system:serviceaccount:production:app-service-account

### Application Logs

> **Screenshot 44**: Application pod logs
> - Command: `kubectl logs -n production [azure-vote-pod] --tail=50`
> - Capture: Logs showing:
>   - Flask app started
>   - No Redis connection errors
>   - HTTP requests being handled

> **Screenshot 45**: Redis pod logs
> - Command: `kubectl logs -n production azure-vote-redis-master-0 --tail=30`
> - Capture: Redis ready to accept connections

---

## 10. Conclusion

### Key Achievements

✅ **Infrastructure as Code**: All Azure resources provisioned via Terraform  
✅ **Containerization**: Application containerized and stored in Azure Container Registry  
✅ **Secrets Management**: Azure Key Vault integration with Workload Identity (passwordless)  
✅ **Package Management**: Helm charts with dependency management (Redis)  
✅ **Storage Integration**: Azure Storage used for static assets (logo image)  
✅ **CI/CD Pipeline**: Azure DevOps pipeline for automated deployment  
✅ **Security**: No hardcoded secrets, RBAC configured, managed identities used  
✅ **High Availability**: 2 replicas for application pods  
✅ **Testing**: Application fully functional and accessible

### Architecture Benefits

1. **Security**: Secrets stored in Key Vault, accessed via Workload Identity (no passwords in code)
2. **Scalability**: Kubernetes-based deployment with easy horizontal scaling
3. **Maintainability**: Helm charts for reproducible deployments
4. **Automation**: Complete CI/CD pipeline for continuous deployment
5. **Observability**: Logs and monitoring via Kubernetes native tools

### Commands Reference

```bash
# Connect to AKS
az aks get-credentials --resource-group [rg-name] --name aks-devsecops-demo

# Deploy via Helm (manual)
helm upgrade azure-vote Assignment/azure-vote-chart-simple/ \
  --install \
  --namespace production \
  --create-namespace \
  --set keyVault.tenantId=[tenant-id] \
  --set keyVault.clientId=[client-id]

# Get application URL
kubectl get svc azure-vote -n production

# View logs
kubectl logs -f -l app=azure-vote -n production

# Check secrets
kubectl get secretproviderclass -n production
kubectl get secret azure-vote-secrets -n production
```

---

## Appendix

### File Structure
```
Assignment/
├── azure-vote/
│   ├── Dockerfile
│   └── azure-vote/
│       ├── main.py
│       └── templates/
│           └── index.html
├── azure-vote-chart-simple/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── serviceaccount.yaml
│       └── secretproviderclass.yaml
├── azure-pipeline-simple-deploy.yml
└── DOCUMENTATION.md (this file)
```

### Resources
- Azure Documentation: https://docs.microsoft.com/azure
- Helm Documentation: https://helm.sh/docs
- Kubernetes Documentation: https://kubernetes.io/docs

---

**End of Documentation**

# End-to-End AKS DevSecOps Demo: Step-by-Step Guide

## 1. Azure Service Principal (Agent) Creation

1. Login to Azure:
   ```sh
   az login
   ```
2. Create a service principal for Terraform (replace with your values):
   ```sh
   az ad sp create-for-rbac --name "tf-agent" --role="Contributor" --scopes="/subscriptions/<subscription-id>"
   ```
3. Note the output: appId, password, and tenant. Use these for your pipeline/service connection.

## 2. Bootstrap Terraform State Storage

1. Run the provided bootstrap script to create the storage account for remote state:
   ```sh
   cd Assignment/bootstrap
   ./create-tfstate-storage.sh
   ```
2. Update `backend.tf` with the actual storage account name and container if needed.

## 3. Infrastructure as Code (IaC) Deployment

1. Set your Azure subscription and login:
   ```sh
   az account set --subscription <subscription-id>
   az login
   ```
2. Initialize Terraform:
   ```sh
   cd Assignment/terraform
   terraform init
   ```
3. Set your tenant_id in `terraform.tfvars` (get it with `az account show --query tenantId -o tsv`).
4. Plan and apply (use two-step apply for AKS OIDC):
   ```sh
   terraform apply -target=module.aks
   terraform apply
   ```

## 4. Application Build and Deployment

1. Build your application Docker image (if needed):
   ```sh
   docker build -t <acr-name>.azurecr.io/azure-vote:latest .
   az acr login --name <acr-name>
   docker push <acr-name>.azurecr.io/azure-vote:latest
   ```
2. Get AKS credentials:
   ```sh
   az aks get-credentials --resource-group <resource-group> --name <aks-name>
   ```
3. Add required secrets to Key Vault:
   ```sh
   az keyvault secret set --vault-name <keyvault-name> --name secret-key --value <your-secret>
   az keyvault secret set --vault-name <keyvault-name> --name redis-password --value <your-redis-password>
   ```
4. Deploy the Helm chart:
   ```sh
   helm upgrade --install azure-vote ./azure-vote-chart --namespace production --create-namespace \
     --set workloadIdentityClientId=<client-id> \
     --set keyvaultName=<keyvault-name> \
     --set tenantId=<tenant-id>
   ```
5. Expose the app (if not already):
   - Ensure your Service is type LoadBalancer for external access.
   - Get the public IP:
     ```sh
     kubectl get svc -n production
     ```

## 5. Validation

- Access the app via the LoadBalancer IP.
- Check pod logs and events if troubleshooting is needed.
- Confirm secrets are loaded from Key Vault and Redis is working.

---

**Replace all placeholder values (e.g., <resource-group>, <keyvault-name>, etc.) with your actual values.**

This guide covers the full workflow from agent/service principal creation, Terraform bootstrap, IaC deployment, to app build and deployment on AKS with secure Key Vault integration.
