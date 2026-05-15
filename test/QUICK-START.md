# ⚡ Quick Start - Azure Vote Deployment

## 🎯 Choose Your Path

### Path A: Full DevSecOps (Recommended for Assessment) ⭐

**Time**: 20-30 minutes  
**Covers**: All assessment requirements  
**Files**: Helm chart + Azure Pipeline

```bash
# 1. Install CSI driver (one-time)
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system --set syncSecret.enabled=true
kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

# 2. Create Key Vault secrets
az keyvault secret set --vault-name kvdevsecopsdemo --name redis-password --value "RedisP@ssw0rd123"
az keyvault secret set --vault-name kvdevsecopsdemo --name secretKey --value "AppSecret456"

# 3. Setup Azure DevOps pipeline
# Follow: AZURE-DEVOPS-SETUP.md
# Use: azure-pipelines-helm-deploy.yml
```

---

### Path B: Quick Test (5 minutes)

**Time**: 5 minutes  
**Use case**: Quick functionality test

```bash
# Get AKS access
az aks get-credentials --resource-group rg-aks-devsecops-demo --name aks-devsecops-demo

# Deploy
kubectl apply -f Assignment/azure-vote-all-in-one-redis.yaml

# Get URL
kubectl get svc azure-vote-front -w
# Wait for EXTERNAL-IP, then open in browser

# Cleanup
kubectl delete -f Assignment/azure-vote-all-in-one-redis.yaml
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| [DEPLOYMENT-OPTIONS.md](DEPLOYMENT-OPTIONS.md) | **START HERE** - Compare all options |
| [MANUAL-DEPLOY.md](MANUAL-DEPLOY.md) | Manual deployment steps |
| [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md) | Pipeline setup guide |
| [FIX-NAMESPACE-MISMATCH.md](FIX-NAMESPACE-MISMATCH.md) | Terraform/Helm namespace fix |
| [QUICK-START.md](QUICK-START.md) | This file |

---

## 🔧 Prerequisites Checklist

Before deploying, ensure you have:

```bash
# ✅ Azure CLI installed
az --version

# ✅ kubectl installed
kubectl version --client

# ✅ Helm installed (for Helm deployment)
helm version

# ✅ Docker installed (for manual image build)
docker --version

# ✅ Terraform applied
cd Assignment/terraform
terraform output

# ✅ AKS access
az aks get-credentials --resource-group rg-aks-devsecops-demo --name aks-devsecops-demo
kubectl get nodes
```

---

## 🚨 Common Issues

### Issue: Pods stuck in "ContainerCreating"
```bash
# Check CSI driver
kubectl get pods -n kube-system -l app=csi-secrets-store-provider-azure

# Install if missing (see Path A step 1)
```

### Issue: Image pull error
```bash
# Verify ACR integration
az aks check-acr --resource-group rg-aks-devsecops-demo --name aks-devsecops-demo --acr acrdevsecopsdemo.azurecr.io
```

### Issue: LoadBalancer IP stuck in "pending"
```bash
# Check service
kubectl describe svc azure-vote-front  # or azure-vote

# Usually takes 2-5 minutes, be patient!
```

### Issue: Workload Identity not working
```bash
# Check namespace matches Terraform
# See: FIX-NAMESPACE-MISMATCH.md
```

---

## 📊 Terraform Values You Need

Get these from your Terraform:

```bash
cd Assignment/terraform

# Workload Identity Client ID
terraform output -raw workload_identity_client_id

# Tenant ID
az account show --query tenantId -o tsv

# ACR Login Server
terraform output -raw acr_login_server

# AKS Cluster Name
terraform output -raw aks_cluster_name
```

---

## 🎓 For Your Assessment Submission

### Include These:

1. ✅ **Screenshots**:
   - Azure DevOps pipeline runs (Build + Deploy)
   - Trivy security scan results
   - AKS pods running (`kubectl get pods`)
   - Application running in browser
   - Key Vault secrets

2. ✅ **Documentation**:
   - Architecture diagram
   - Deployment steps taken
   - Troubleshooting notes
   - Security measures implemented

3. ✅ **Code**:
   - Terraform files
   - Helm chart
   - Azure Pipeline YAML
   - Dockerfile

4. ✅ **Validation**:
   - App is accessible
   - Redis connection works (voting works)
   - Secrets from Key Vault
   - Security scan passed

---

## 🏆 Assessment Criteria Coverage

| Criteria | How to Demonstrate |
|----------|-------------------|
| **Azure DevOps** | Show pipeline YAML and execution logs |
| **Docker/Containerization** | Dockerfile + ACR image |
| **AKS Deployment** | `kubectl get all` output |
| **ACR Integration** | Pipeline push/pull steps |
| **Key Vault** | SecretProviderClass + mounted secrets |
| **Helm** | Helm chart structure + `helm list` |
| **Security** | Trivy scan results |
| **Documentation** | This comprehensive guide |

---

## 🎯 Success Checklist

Before submitting:

- [ ] Terraform successfully provisioned resources
- [ ] Docker image built and pushed to ACR
- [ ] Security scan completed (Trivy)
- [ ] Helm chart deploys successfully
- [ ] Pods running and healthy
- [ ] Application accessible via LoadBalancer
- [ ] Voting functionality works (tests Redis)
- [ ] Secrets pulled from Key Vault
- [ ] Azure DevOps pipeline working end-to-end
- [ ] Documentation completed
- [ ] Screenshots captured
- [ ] Code committed to repo

---

## 📞 Quick Help

```bash
# View all resources
kubectl get all -n voting-app

# Check pod logs
kubectl logs -l app=azure-vote -n voting-app

# Describe pod issues
kubectl describe pod <pod-name> -n voting-app

# Check Helm releases
helm list -n voting-app

# View Key Vault secrets
az keyvault secret list --vault-name kvdevsecopsdemo -o table
```

---

## 🚀 Ready to Deploy?

1. **Review** → Read [DEPLOYMENT-OPTIONS.md](DEPLOYMENT-OPTIONS.md)
2. **Choose** → Pick Path A (full) or Path B (quick test)
3. **Deploy** → Follow the guide
4. **Validate** → Use success checklist
5. **Document** → Take screenshots
6. **Submit** → Package everything

**Good luck with your assessment!** 🎉
