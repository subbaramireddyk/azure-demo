# Azure Pipelines Overview

Quick reference for all available pipelines.

---

## 📦 Available Pipelines

| Pipeline | Build | Deploy | Key Vault | Complexity | Best For |
|----------|-------|--------|-----------|------------|----------|
| **[azure-pipelines-helm-deploy.yml](azure-pipelines-helm-deploy.yml)** | ✅ | ✅ | ✅ | High | Full Assessment ⭐⭐⭐ |
| **[azure-pipelines-deploy-only.yml](azure-pipelines-deploy-only.yml)** | ❌ | ✅ | ✅ | Medium | Deploy Only (Helm) ⭐⭐ |
| **[azure-pipelines-deploy-simple.yml](azure-pipelines-deploy-simple.yml)** | ❌ | ✅ | ❌ | Low | Quick Deploy ⭐ |
| **[azure-pipelines-simple.yml](azure-pipelines-simple.yml)** | ❌ | ✅ | ❌ | Low | Basic CI/CD |

---

## 🎯 Pipeline Details

### 1. Full DevSecOps Pipeline (Recommended for Assessment) ⭐⭐⭐

**File**: `azure-pipelines-helm-deploy.yml`

**What it does**:
```
Stage 1: Build
├── Build Docker image
├── Scan with Trivy (security)
└── Push to ACR

Stage 2: Deploy
├── Get AKS credentials
├── Get Azure configuration
├── Deploy with Helm
├── Verify deployment
└── Get application URL
```

**Requirements**:
- Azure service connection
- ACR service connection
- Kubernetes service connection
- CSI driver installed

**When to use**: Full assessment submission with all requirements

**Setup Guide**: [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md)

---

### 2. Deploy Only with Helm ⭐⭐

**File**: `azure-pipelines-deploy-only.yml`

**What it does**:
```
Stage: Deploy
├── Connect to AKS
├── Get Azure configuration
├── Update Helm dependencies
├── Deploy with Helm
├── Verify deployment
└── Get application URL
```

**Requirements**:
- Azure service connection
- Image already in ACR
- CSI driver installed
- Key Vault secrets created

**When to use**: 
- Image already built manually
- Testing Helm deployment
- Separating build and deploy

**Setup Guide**: [DEPLOY-PIPELINES-SETUP.md](DEPLOY-PIPELINES-SETUP.md)

---

### 3. Simple Deploy (No Helm) ⭐

**File**: `azure-pipelines-deploy-simple.yml`

**What it does**:
```
Stage: Deploy
├── Connect to AKS
├── Deploy YAML manifest
├── Wait for pods ready
└── Get application URL
```

**Requirements**:
- Azure service connection
- No other dependencies

**When to use**:
- Quick testing
- No Key Vault needed
- Simplest deployment

**Setup Guide**: [DEPLOY-PIPELINES-SETUP.md](DEPLOY-PIPELINES-SETUP.md)

---

## 🚀 Quick Start Commands

### Create Pipeline in Azure DevOps:

1. Go to **Pipelines** → **New pipeline**
2. Choose **Azure Repos Git**
3. Select repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select one of the YAML files above
6. Update service connection names
7. Save and run

---

## ⚙️ Configuration Comparison

### Variables to Update

#### Full Pipeline (azure-pipelines-helm-deploy.yml):
```yaml
azureServiceConnection: 'your-connection-name'
acrServiceConnection: 'your-acr-connection'
kubernetesServiceConnection: 'your-k8s-connection'
imageTag: '$(Build.BuildId)'  # Auto-generated
```

#### Deploy Only (azure-pipelines-deploy-only.yml):
```yaml
azureServiceConnection: 'your-connection-name'
imageTag: 'v1'  # ⚠️ Set your image tag
```

#### Simple Deploy (azure-pipelines-deploy-simple.yml):
```yaml
azureServiceConnection: 'your-connection-name'
```

---

## 📊 Feature Comparison

| Feature | Full | Deploy Only | Simple |
|---------|------|-------------|--------|
| **Build Docker image** | ✅ | ❌ | ❌ |
| **Security scan** | ✅ Trivy | ❌ | ❌ |
| **Push to ACR** | ✅ | ❌ | ❌ |
| **Helm deployment** | ✅ | ✅ | ❌ |
| **Key Vault** | ✅ | ✅ | ❌ |
| **Workload Identity** | ✅ | ✅ | ❌ |
| **Health checks** | ✅ | ✅ | ✅ |
| **Get URL** | ✅ | ✅ | ✅ |
| **Show logs** | ✅ | ✅ | ✅ |

---

## 🎓 Recommendation for Assessment

### Best Approach:

**Option 1**: Use Full Pipeline (all-in-one) ⭐⭐⭐
```
azure-pipelines-helm-deploy.yml
```
**Pro**: Covers all requirements in one pipeline  
**Con**: Most complex to set up

---

**Option 2**: Separate Build and Deploy ⭐⭐
```
1. Build image manually or separate pipeline
2. Use azure-pipelines-deploy-only.yml
```
**Pro**: Cleaner separation of concerns  
**Con**: Two steps instead of one

---

**Option 3**: Quick Demo ⭐
```
azure-pipelines-deploy-simple.yml
```
**Pro**: Easiest to set up  
**Con**: Missing Key Vault requirement

---

## 🔄 Typical Workflow

### Development Flow:

```
1. Code changes
   ↓
2. Build Pipeline runs
   ├── Build image
   ├── Scan
   └── Push to ACR
   ↓
3. Deploy Pipeline runs
   ├── Deploy to DEV
   ├── Test
   └── Deploy to PROD
```

### For Your Assessment:

```
1. Setup:
   ├── Terraform (done ✅)
   ├── Build image manually
   └── Create Key Vault secrets
   ↓
2. Pipeline:
   ├── Choose pipeline
   ├── Update variables
   └── Run
   ↓
3. Validate:
   ├── Check pods
   ├── Test application
   └── Take screenshots
```

---

## 📸 Screenshots to Take

For each pipeline, capture:

1. ✅ Pipeline YAML configuration
2. ✅ Pipeline run summary
3. ✅ Build stage logs (if applicable)
4. ✅ Deploy stage logs
5. ✅ Security scan results (if applicable)
6. ✅ Deployment verification output
7. ✅ Application URL
8. ✅ Working application in browser

---

## 🔧 Common Issues

### All Pipelines:

| Issue | Solution |
|-------|----------|
| Service connection not found | Update variable to match your connection name |
| AKS access denied | Grant service principal access to AKS |
| Timeout waiting for pods | Check pod logs, increase timeout |

### Helm Pipelines Only:

| Issue | Solution |
|-------|----------|
| CSI driver not found | Install CSI Secret Store driver |
| Workload Identity fails | Check namespace matches Terraform |
| Key Vault access denied | Verify RBAC permissions |

### Full Pipeline Only:

| Issue | Solution |
|-------|----------|
| ACR connection failed | Create ACR service connection |
| Trivy scan fails | Check internet connectivity |
| Build fails | Verify Dockerfile path |

---

## 📚 Related Documentation

- [AZURE-DEVOPS-SETUP.md](AZURE-DEVOPS-SETUP.md) - Full pipeline setup
- [DEPLOY-PIPELINES-SETUP.md](DEPLOY-PIPELINES-SETUP.md) - Deploy-only setup
- [QUICK-START.md](QUICK-START.md) - Quick reference
- [DEPLOYMENT-OPTIONS.md](DEPLOYMENT-OPTIONS.md) - All deployment methods

---

## 🎯 Decision Tree

```
Do you need to build Docker image?
│
├─ YES → Use azure-pipelines-helm-deploy.yml (Full)
│
└─ NO → Do you need Key Vault integration?
         │
         ├─ YES → Use azure-pipelines-deploy-only.yml (Helm)
         │
         └─ NO → Use azure-pipelines-deploy-simple.yml (Simple)
```

---

## ✅ Final Checklist

Before running any pipeline:

- [ ] Service connection created
- [ ] Variables updated in YAML
- [ ] Prerequisites installed (if Helm)
- [ ] Image in ACR (if deploy-only)
- [ ] Key Vault secrets (if Helm)
- [ ] Namespace decision made
- [ ] Terraform applied

**Ready to deploy!** 🚀
