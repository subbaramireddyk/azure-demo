# Azure DevSecOps Assessment - Azure Vote Application Deployment

**Candidate**: [Your Name]  
**Date**: April 21, 2026  
**Assessment Duration**: 48 hours

[[_TOC_]]

---

## 1. Architecture Overview

### Solution Architecture Diagram

Create/draw architecture diagram showing:
- AKS Cluster
- Azure Container Registry
- Azure Key Vault
- Azure Storage Account
- Azure DevOps Pipeline
- Workload Identity flow

![Architecture Diagram](/.attachments/01-architecture-diagram.png)

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

Infrastructure as Code was used to provision all Azure resources.

**Screenshot 1: Terraform Files Structure**

```bash
tree terraform/
```

![Terraform Structure](/.attachments/02-terraform-structure.png)

**Screenshot 2: Terraform Apply Output**

```bash
terraform apply
```

![Terraform Apply](/.attachments/03-terraform-apply.png)

**Screenshot 3: Azure Portal - Resource Group**

Navigate to: Azure Portal → Resource Groups → [your-rg-name]

![Resource Group](/.attachments/04-resource-group.png)

### Key Resources Provisioned

- ✅ AKS Cluster with Workload Identity enabled
- ✅ Azure Container Registry with admin enabled
- ✅ Azure Key Vault with access policies
- ✅ Azure Storage Account
- ✅ Federated Identity Credentials for workload authentication

---

## 3. Container Registry

### Docker Image Build & Push

**Screenshot 4: Docker Build Command**

```bash
docker build -t acrdevsecopsdemo.azurecr.io/azure-vote:latest .
```

![Docker Build](/.attachments/05-docker-build.png)

**Screenshot 5: ACR Login and Push**

```bash
az acr login --name acrdevsecopsdemo
docker push acrdevsecopsdemo.azurecr.io/azure-vote:latest
```

![Docker Push](/.attachments/06-docker-push.png)

**Screenshot 6: Azure Portal - ACR Repositories**

Navigate to: Azure Portal → Container Registry → acrdevsecopsdemo → Repositories

![ACR Repositories](/.attachments/07-acr-repositories.png)

---

## 4. Azure Key Vault Integration

### Secrets Configuration

**Screenshot 7: Key Vault Secrets Creation**

```bash
az keyvault secret set --vault-name kvdevsecopsdemo --name redis-password --value "RedisP@ssw0rd123"
az keyvault secret set --vault-name kvdevsecopsdemo --name secretKey --value "YourSecretKey123"
```

![Create Secrets](/.attachments/08-create-secrets.png)

**Screenshot 8: Azure Portal - Key Vault Secrets**

Navigate to: Azure Portal → Key Vault → kvdevsecopsdemo → Secrets

![Key Vault Secrets](/.attachments/09-keyvault-secrets.png)

**Screenshot 9: Workload Identity Configuration**

Navigate to: Azure Portal → Key Vault → Access configuration

![Workload Identity](/.attachments/10-workload-identity.png)

### Secrets Access from Pods

**Screenshot 10: SecretProviderClass YAML**

File: `Assignment/azure-vote-chart-simple/templates/secretproviderclass.yaml`

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-vote-spc
spec:
  provider: azure
  parameters:
    clientID: {{ .Values.keyVault.clientId | quote }}
    keyvaultName: {{ .Values.keyVault.name | quote }}
    tenantId: {{ .Values.keyVault.tenantId | quote }}
```

![SecretProviderClass](/.attachments/11-secretproviderclass.png)

**Screenshot 11: Deployed SecretProviderClass**

```bash
kubectl get secretproviderclass -n production
```

![Get SecretProviderClass](/.attachments/12-get-spc.png)

**Screenshot 12: Kubernetes Secret Created by CSI Driver**

```bash
kubectl get secret azure-vote-secrets -n production -o yaml
```

![K8s Secret](/.attachments/13-k8s-secret.png)

---

## 5. Helm Chart Implementation

### Chart Structure

**Screenshot 13: Helm Chart Directory Structure**

```bash
tree Assignment/azure-vote-chart-simple/
```

![Helm Chart Structure](/.attachments/14-helm-structure.png)

**Screenshot 14: Chart.yaml with Redis Dependency**

File: `Assignment/azure-vote-chart-simple/Chart.yaml`

```yaml
dependencies:
  - name: redis
    version: "19.0.2"
    repository: "https://charts.bitnami.com/bitnami"
```

![Chart.yaml](/.attachments/15-chart-yaml.png)

**Screenshot 15: values.yaml Configuration**

File: `Assignment/azure-vote-chart-simple/values.yaml`

![values.yaml](/.attachments/16-values-yaml.png)

### Helm Dependency Management

**Screenshot 16: Helm Dependency Update**

```bash
helm dependency update Assignment/azure-vote-chart-simple/
```

![Helm Dependency Update](/.attachments/17-helm-dep-update.png)

**Screenshot 17: Chart Dependencies Downloaded**

```bash
ls -la Assignment/azure-vote-chart-simple/charts/
```

![Charts Downloaded](/.attachments/18-charts-folder.png)

---

## 6. Azure Storage Integration

### Storage Container Setup

**Screenshot 18: Storage Container Creation**

```bash
az storage container create --name vote-assets --account-name stdevsecopsdemo --public-access blob
```

![Create Container](/.attachments/19-create-container.png)

**Screenshot 19: Logo Upload to Storage**

```bash
az storage blob upload --account-name stdevsecopsdemo --container-name vote-assets --name logo.png --file logo.png
```

![Upload Logo](/.attachments/20-upload-logo.png)

**Screenshot 20: Azure Portal - Storage Container**

Navigate to: Azure Portal → Storage Account → stdevsecopsdemo → Containers → vote-assets

![Storage Container](/.attachments/21-storage-container.png)

**Screenshot 21: Public Blob URL Accessible**

```bash
curl -I https://stdevsecopsdemo.blob.core.windows.net/vote-assets/logo.png
```

![Blob URL Test](/.attachments/22-blob-url-test.png)

### Application Integration

**Screenshot 22: HTML Code Using Storage URL**

File: `Assignment/azure-vote/azure-vote/templates/index.html`

```html
<img src="https://stdevsecopsdemo.blob.core.windows.net/vote-assets/logo.png" alt="Azure Vote Logo">
```

![HTML Storage Integration](/.attachments/23-html-storage.png)

---

## 7. CI/CD Pipeline

### Azure DevOps Setup

**Screenshot 23: Pipeline Variables Configuration**

Navigate to: Azure DevOps → Pipelines → [Your Pipeline] → Edit → Variables

![Pipeline Variables](/.attachments/24-pipeline-variables.png)

**Screenshot 24: Kubernetes Service Connection**

Navigate to: Azure DevOps → Project Settings → Service Connections

![Service Connection](/.attachments/25-service-connection.png)

### Pipeline Configuration

**Screenshot 25: Pipeline YAML File**

File: `Assignment/azure-pipeline-simple-deploy.yml`

![Pipeline YAML](/.attachments/26-pipeline-yaml.png)

**Screenshot 26: Pipeline Run - Overview**

Navigate to: Azure DevOps → Pipelines → Runs → [Latest Run]

![Pipeline Run Overview](/.attachments/27-pipeline-run-overview.png)

**Screenshot 27: Pipeline Run - Helm Deploy Step**

Navigate to: Pipeline run → Deploy stage → DeployApp job → "Deploy to AKS" step

![Helm Deploy Step](/.attachments/28-helm-deploy-step.png)

**Screenshot 28: Pipeline Run - Application Reachability Test**

Navigate to: Same run → "Test Application is Reachable" step

![Reachability Test](/.attachments/29-reachability-test.png)

---

## 8. Application Deployment

### Kubernetes Resources

**Screenshot 29: All Deployed Resources**

```bash
kubectl get all -n production
```

![All Resources](/.attachments/30-get-all.png)

**Screenshot 30: Azure Vote Deployment Details**

```bash
kubectl describe deployment azure-vote -n production
```

![Deployment Details](/.attachments/31-deployment-details.png)

**Screenshot 31: Azure Vote Pods Running**

```bash
kubectl get pods -n production -l app=azure-vote
```

![Pods Running](/.attachments/32-pods-running.png)

**Screenshot 32: Pod Describe Showing Workload Identity**

```bash
kubectl describe pod [azure-vote-pod] -n production
```

![Pod Details](/.attachments/33-pod-details.png)

**Screenshot 33: Redis StatefulSet Running**

```bash
kubectl get statefulset -n production
```

![Redis StatefulSet](/.attachments/34-redis-statefulset.png)

**Screenshot 34: Service with LoadBalancer IP**

```bash
kubectl get svc azure-vote -n production
```

![Service LoadBalancer](/.attachments/35-service-lb.png)

---

## 9. Testing & Verification

### Application Functionality

**Screenshot 35: Application Homepage - Browser**

URL: http://[EXTERNAL-IP]

![Application Homepage](/.attachments/36-app-homepage.png)

**Screenshot 36: Browser DevTools - Network Tab**

Action: Refresh page with DevTools open (F12 → Network)

Show logo loaded from: `stdevsecopsdemo.blob.core.windows.net/vote-assets/logo.png`

![DevTools Network](/.attachments/37-devtools-network.png)

**Screenshot 37: Vote Functionality Test**

Action: Click "Cats" button multiple times

![Vote Test](/.attachments/38-vote-test.png)

**Screenshot 38: Reset Functionality**

Action: Click "Reset" button

![Reset Test](/.attachments/39-reset-test.png)

### Security Verification

**Screenshot 39: Pod Environment Variables**

```bash
kubectl exec -n production [azure-vote-pod] -- env | grep -E 'REDIS|AZURE'
```

![Pod Env Vars](/.attachments/40-pod-env.png)

**Screenshot 40: Secret Mounted in Pod**

```bash
kubectl exec -n production [azure-vote-pod] -- ls -la /mnt/secrets-store/
```

![Secrets Mounted](/.attachments/41-secrets-mounted.png)

**Screenshot 41: Verify Secret Content Matches Key Vault**

```bash
kubectl exec -n production [azure-vote-pod] -- cat /mnt/secrets-store/redis-password
```

![Secret Content](/.attachments/42-secret-content.png)

### Workload Identity Verification

**Screenshot 42: ServiceAccount with Workload Identity Annotation**

```bash
kubectl get sa app-service-account -n production -o yaml
```

![ServiceAccount](/.attachments/43-serviceaccount.png)

**Screenshot 43: Federated Identity Credential in Azure**

Navigate to: Azure Portal → Managed Identity → [workload-identity-name] → Federated credentials

![Federated Credential](/.attachments/44-federated-credential.png)

### Application Logs

**Screenshot 44: Application Pod Logs**

```bash
kubectl logs -n production [azure-vote-pod] --tail=50
```

![App Logs](/.attachments/45-app-logs.png)

**Screenshot 45: Redis Pod Logs**

```bash
kubectl logs -n production azure-vote-redis-master-0 --tail=30
```

![Redis Logs](/.attachments/46-redis-logs.png)

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
└── DOCUMENTATION.md
```

### Resources

- [Azure Documentation](https://docs.microsoft.com/azure)
- [Helm Documentation](https://helm.sh/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [Azure Workload Identity](https://azure.github.io/azure-workload-identity)

---

**End of Documentation**
