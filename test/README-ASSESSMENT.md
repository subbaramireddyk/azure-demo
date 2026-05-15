# Azure DevSecOps Assessment - Azure Vote Application

Complete DevSecOps solution for deploying a microservices application (Azure Vote) to AKS with ACR, Key Vault, and Helm.

---

## 🚀 Quick Start

### ⚡ For Assessment Submission (Recommended):

1. **Read First**: [QUICK-START.md](QUICK-START.md)
2. **Choose Path**: [DEPLOYMENT-OPTIONS.md](DEPLOYMENT-OPTIONS.md)
3. **Deploy**: [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md)

### For Quick Test (5 minutes):

```bash
az aks get-credentials --resource-group rg-aks-devsecops-demo --name aks-devsecops-demo
kubectl apply -f azure-vote-all-in-one-redis.yaml
kubectl get svc azure-vote-front
```

---

## 📁 What You Have

✅ **Terraform Infrastructure** - All Azure resources provisioned  
✅ **Helm Chart** - Production-ready with Key Vault integration  
✅ **Azure Pipelines** - Full DevSecOps CI/CD  
✅ **Documentation** - Complete guides for everything  
✅ **Application Code** - Azure Vote Flask app  

---

## 🎯 Assessment Requirements ✅

| Requirement | Status | Location |
|-------------|--------|----------|
| Azure DevOps Project | ✅ Manual | Azure DevOps portal |
| Build Pipeline | ✅ Ready | `azure-pipelines-helm-deploy.yml` |
| Security Scanning | ✅ Trivy | Pipeline included |
| Key Vault Integration | ✅ Ready | Helm chart + Terraform |
| Azure Storage | ✅ Provisioned | Terraform |
| AKS Deployment | ✅ Ready | Both manual & pipeline |
| Helm Charts | ✅ Complete | `azure-vote-chart-simple/` |
| Documentation | ✅ Complete | All `.md` files |

---

## 📚 Documentation Guide

| File | When to Use |
|------|-------------|
| **[QUICK-START.md](QUICK-START.md)** | ⚡ Start here - Quick commands |
| **[DEPLOYMENT-OPTIONS.md](DEPLOYMENT-OPTIONS.md)** | Compare 4 deployment methods |
| **[MANUAL-DEPLOY.md](MANUAL-DEPLOY.md)** | Deploy manually (local) |
| **[AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md)** | Setup CI/CD pipeline |
| **[FIX-NAMESPACE-MISMATCH.md](FIX-NAMESPACE-MISMATCH.md)** | Fix Workload Identity issues |

---

## 🎓 Recommended Path for Assessment

### Day 1 Morning: Test Everything
```bash
# Manual deployment to verify
cd Assignment/azure-vote-chart-simple
helm dependency update
helm install azure-vote . -n voting-app --create-namespace
```

### Day 1 Afternoon: Build Pipeline
- Setup Azure DevOps service connections
- Import `azure-pipelines-helm-deploy.yml`
- Run and validate

### Day 2: Document & Submit
- Take screenshots
- Write deployment notes
- Package and submit

---

## 📦 Project Structure

```
Assignment/
├── terraform/                          # Infrastructure (already applied)
├── azure-vote/                         # Application source
├── azure-vote-chart-simple/           # Helm chart ⭐
├── azure-pipelines-helm-deploy.yml    # Full pipeline ⭐⭐⭐
├── azure-pipelines-simple.yml         # Basic pipeline
├── azure-vote-all-in-one-redis.yaml   # Quick test
└── [Documentation].md                  # All guides
```

---

## 🔑 Get Your Configuration Values

```bash
cd Assignment/terraform

# Workload Identity Client ID (IMPORTANT!)
terraform output -raw workload_identity_client_id

# Tenant ID
az account show --query tenantId -o tsv

# ACR Server
terraform output -raw acr_login_server

# Update in: azure-vote-chart-simple/values.yaml
```

---

## ✅ Success Checklist

Before submitting:

- [ ] Terraform outputs show all resources
- [ ] Docker image in ACR
- [ ] Security scan completed
- [ ] Helm chart deploys successfully
- [ ] Application accessible via browser
- [ ] Voting works (tests Redis)
- [ ] Secrets from Key Vault
- [ ] Pipeline runs end-to-end
- [ ] Screenshots captured
- [ ] Documentation complete

---

## 🚨 Most Common Issues

1. **Namespace mismatch** → [FIX-NAMESPACE-MISMATCH.md](FIX-NAMESPACE-MISMATCH.md)
2. **CSI driver missing** → Install in [MANUAL-DEPLOY.md](MANUAL-DEPLOY.md)
3. **Workload Identity fails** → Check client ID in values.yaml
4. **Image pull error** → Verify ACR integration

---

## 📞 Quick Commands

```bash
# View everything
kubectl get all -n voting-app

# Check logs
kubectl logs -l app=azure-vote -n voting-app

# Get URL
kubectl get svc azure-vote -n voting-app

# Cleanup
helm uninstall azure-vote -n voting-app
```

---

## 🏆 You're Ready!

Everything is prepared for your assessment. Follow the guides, take screenshots, and submit with confidence!

**Start with**: [QUICK-START.md](QUICK-START.md) ⚡

Good luck! 🎉
