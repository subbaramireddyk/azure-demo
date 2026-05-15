# Deployment Options - Choose Your Path

You have **4 deployment options** for the Azure Vote app. Choose based on your assessment goals and time constraints.

---

## 🎯 Quick Comparison

| Method | Time | Key Vault | Helm | DevSecOps | Best For |
|--------|------|-----------|------|-----------|----------|
| **1. Simple YAML (Manual)** | 5 min | ❌ | ❌ | ⚠️ Basic | Quick demo |
| **2. Simple YAML (Pipeline)** | 10 min | ❌ | ❌ | ✅ CI/CD | Basic automation |
| **3. Helm Chart (Manual)** | 15 min | ✅ | ✅ | ✅ Full | Learning/Testing |
| **4. Helm Chart (Pipeline)** | 20 min | ✅ | ✅ | ✅✅ Full | **Assessment** ⭐ |

---

## Option 1: Simple YAML - Manual Deployment

**Files**: `azure-vote-all-in-one-redis.yaml`  
**Guide**: [MANUAL-DEPLOY.md](MANUAL-DEPLOY.md) - Option B

### Pros:
- ✅ Fastest (5 minutes)
- ✅ No dependencies
- ✅ Easy to understand

### Cons:
- ❌ No Key Vault integration
- ❌ No secrets management
- ❌ Hardcoded values
- ❌ Not production-ready

### When to Use:
- Quick functionality test
- Learning Kubernetes basics
- Time-constrained demo

### Commands:
```bash
az aks get-credentials --resource-group rg-aks-devsecops-demo --name aks-devsecops-demo
kubectl apply -f Assignment/azure-vote-all-in-one-redis.yaml
kubectl get svc azure-vote-front
```

---

## Option 2: Simple YAML - Azure DevOps Pipeline

**Files**: `azure-pipelines-simple.yml`  
**Guide**: [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md) - Option B

### Pros:
- ✅ Automated CI/CD
- ✅ Easy to set up
- ✅ Shows pipeline skills
- ✅ Faster than Helm

### Cons:
- ❌ No Key Vault (misses assessment requirement)
- ❌ No Helm (misses assessment requirement)
- ⚠️ Less impressive for assessment

### When to Use:
- Pipeline practice
- CI/CD demonstration
- Backup if Helm doesn't work

### Setup:
1. Create service connections in Azure DevOps
2. Import `azure-pipelines-simple.yml`
3. Update service connection name
4. Run pipeline

---

## Option 3: Helm Chart - Manual Deployment

**Files**: `azure-vote-chart-simple/`  
**Guide**: [MANUAL-DEPLOY.md](MANUAL-DEPLOY.md) - Option A

### Pros:
- ✅ Key Vault integration ⭐
- ✅ Workload Identity ⭐
- ✅ Helm package management ⭐
- ✅ Configurable via values.yaml
- ✅ Production-ready

### Cons:
- ⚠️ Takes longer (~15 min)
- ⚠️ More setup required
- ⚠️ Needs CSI driver installation

### When to Use:
- Testing before pipeline
- Understanding Helm charts
- Troubleshooting

### Steps:
1. Install CSI Secret Store driver
2. Create Key Vault secrets
3. Build & push image to ACR
4. Update Helm values
5. Deploy with `helm install`

---

## Option 4: Helm Chart - Azure DevOps Pipeline ⭐⭐⭐

**Files**: `azure-pipelines-helm-deploy.yml`  
**Guide**: [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md)

### Pros:
- ✅✅ **BEST FOR ASSESSMENT** ⭐⭐⭐
- ✅ Meets ALL requirements
- ✅ Full DevSecOps pipeline
- ✅ Image security scanning (Trivy)
- ✅ Key Vault integration
- ✅ Helm deployment
- ✅ ACR integration
- ✅ Automated workflow

### Cons:
- ⚠️ Most complex setup
- ⚠️ Takes longest (~20 min first time)
- ⚠️ More troubleshooting potential

### When to Use:
- **Your actual assessment submission** ⭐
- Showcasing full DevSecOps skills
- Production-grade deployment

### Pipeline Features:
- 🔨 Build Docker image
- 🔍 Security scan with Trivy
- 📦 Push to ACR
- 🚀 Deploy with Helm
- 🔐 Key Vault secrets
- ✅ Health checks

---

## 🎓 Recommendation for Your Assessment

### For 48-Hour Hands-on Lab:

**Primary Approach** (Best Score):
```
Option 4: Helm Chart via Azure DevOps Pipeline
```

**Backup Approach** (If time constrained):
```
Option 3: Helm Chart Manual → Then add pipeline later
```

**Emergency Fallback** (If blocked):
```
Option 2: Simple YAML Pipeline → Show you understand CI/CD
```

---

## 📋 Assessment Requirements Coverage

| Requirement | Option 1 | Option 2 | Option 3 | Option 4 |
|-------------|----------|----------|----------|----------|
| Build Pipeline | ❌ | ✅ | ❌ | ✅ |
| ACR Push | ❌ | ❌ | Manual | ✅ |
| Security Scanning | ❌ | ❌ | ❌ | ✅ |
| Key Vault Integration | ❌ | ❌ | ✅ | ✅ |
| AKS Deployment | ✅ | ✅ | ✅ | ✅ |
| Helm Charts | ❌ | ❌ | ✅ | ✅ |
| Release Pipeline | ❌ | ✅ | ❌ | ✅ |
| Documentation | ⚠️ | ⚠️ | ✅ | ✅ |
| DevSecOps Practices | ❌ | ⚠️ | ✅ | ✅✅ |

---

## 🚀 Quick Start Commands

### Option 1 (Simple Manual):
```bash
kubectl apply -f Assignment/azure-vote-all-in-one-redis.yaml
```

### Option 2 (Simple Pipeline):
```bash
# In Azure DevOps: New Pipeline → Existing YAML
# Select: azure-pipelines-simple.yml
```

### Option 3 (Helm Manual):
```bash
cd Assignment/azure-vote-chart-simple
helm dependency update
helm install azure-vote . -n voting-app --create-namespace
```

### Option 4 (Helm Pipeline):
```bash
# In Azure DevOps: New Pipeline → Existing YAML
# Select: azure-pipelines-helm-deploy.yml
```

---

## 🎯 My Recommendation

For your **48-hour assessment**, I recommend:

### Day 1 (Morning):
1. ✅ Run Option 3 (Helm Manual) to test everything works
2. ✅ Verify Key Vault integration
3. ✅ Take screenshots

### Day 1 (Afternoon):
4. ✅ Set up Azure DevOps service connections
5. ✅ Create Option 4 pipeline
6. ✅ Fix any issues

### Day 2:
7. ✅ Document everything
8. ✅ Add security scan results
9. ✅ Create presentation/report
10. ✅ Submit

This gives you a **production-grade solution** that covers all assessment criteria! 🏆

---

## Need Help?

- Check [MANUAL-DEPLOY.md](MANUAL-DEPLOY.md) for manual steps
- Check [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md) for pipeline setup
- Check [FIX-NAMESPACE-MISMATCH.md](FIX-NAMESPACE-MISMATCH.md) for Workload Identity issues
