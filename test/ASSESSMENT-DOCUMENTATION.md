# Azure AKS DevSecOps Lab Assessment - Documentation Summary

## Assessment Overview
This project demonstrates a complete DevSecOps implementation for deploying a microservices application (Azure Vote) on Azure Kubernetes Service (AKS) using Infrastructure as Code, secure CI/CD pipelines, and best practices.

---

## Architecture Diagram (For Interview)

```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure DevOps                                  │
│  ┌────────────────┐              ┌─────────────────┐            │
│  │ IaC Pipeline   │              │  CD Pipeline    │            │
│  │ (Terraform)    │──────────────│  (Helm)         │            │
│  └────────────────┘              └─────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                    │                         │
                    ▼                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Azure Cloud                              │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Resource     │  │ Storage      │  │ Key Vault    │          │
│  │ Group        │  │ Account      │  │ (Secrets)    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐          │
│  │          AKS Cluster (Kubernetes)                 │          │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐ │          │
│  │  │ azure-vote │  │   Redis    │  │ CSI Driver │ │          │
│  │  │  (Front)   │──│  (Backend) │  │ (Secrets)  │ │          │
│  │  └────────────┘  └────────────┘  └────────────┘ │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                  │
│  ┌──────────────┐                                               │
│  │ Azure        │  (Pulls container images)                     │
│  │ Container    │◄──────────────────────────────────            │
│  │ Registry     │                                               │
│  └──────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure (For Interview Explanation)

```
Assignment/
├── azure-vote-chart/               # Helm chart for application deployment
│   ├── Chart.yaml                  # Chart metadata and Redis dependency
│   ├── values.yaml                 # Configurable parameters
│   └── templates/                  # Kubernetes manifests
│       ├── deployment.yaml         # Application deployment
│       ├── service.yaml            # Service (LoadBalancer)
│       ├── configmap.yaml          # Configuration data
│       └── ingress.yaml            # Optional ingress (disabled)
│
├── terraform/                      # Infrastructure as Code
│   ├── main.tf                     # Main configuration
│   ├── backend.tf                  # Remote state configuration
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values for pipelines
│   ├── terraform.tfvars            # Variable values
│   └── modules/                    # Modular infrastructure
│       ├── aks/                    # AKS cluster module
│       ├── acr/                    # Azure Container Registry module
│       ├── keyvault/               # Key Vault module
│       └── storage/                # Storage Account module
│
├── bootstrap/                      # Pre-deployment scripts
│   └── create-tfstate-storage.sh   # Remote state setup script
│
├── azure-pipelines-iac.yml         # Infrastructure deployment pipeline
├── azure-pipelines-cd.yml          # Application deployment pipeline
├── DEPLOYMENT-CHECKLIST.txt        # Deployment steps
└── AGENT-SETUP-MANUAL.md           # Self-hosted agent setup
```

---

## Deliverable #1: Helm Chart

**Location:** `azure-vote-chart/`

**What It Does:**
- Packages the Azure Vote application and Redis as a deployable unit
- Uses Helm for templating and parameterization
- Manages application configuration via ConfigMap

**Key Features:**
- Redis as a chart dependency (Bitnami subchart)
- Configurable image repository and tag
- Service exposed as LoadBalancer
- ConfigMap for application settings
- Ingress support (disabled by default)

**Interview Talking Points:**
- "I chose Helm for its templating capabilities and dependency management"
- "The Redis dependency is managed as a subchart from Bitnami's repository"
- "Values can be overridden at deployment time for different environments"
- "The chart follows Helm best practices with helpers and labels"

---

## Deliverable #2: Terraform Infrastructure as Code

**Location:** `terraform/`

**What It Does:**
- Provisions all Azure infrastructure in a modular, reusable way
- Creates AKS cluster, ACR, Key Vault, and Storage Account
- Configures security and permissions automatically
- Manages infrastructure state remotely

**Key Components:**

### Main Infrastructure (main.tf)
- Resource Group
- AKS Cluster (with SystemAssigned managed identity)
- Azure Container Registry
- Azure Key Vault
- Azure Storage Account
- CSI Driver for Key Vault (installed via Helm provider)
- Role Assignments (AKS → ACR, AKS → Key Vault)

### Modules
- **aks/**: Configures AKS cluster with node pool and identity
- **acr/**: Creates container registry with SKU options
- **keyvault/**: Creates Key Vault with tenant ID and SKU
- **storage/**: Creates storage account with replication

### Backend Configuration (backend.tf)
- Remote state in Azure Storage
- Terraform and provider version constraints
- Shared state for team collaboration

### Outputs (outputs.tf)
- AKS cluster name and resource group
- ACR login server
- Key Vault URI
- Storage account details
- Used by downstream pipelines

**Interview Talking Points:**
- "I used a modular approach for reusability and maintainability"
- "The Helm provider automates CSI driver installation for Key Vault secrets"
- "SystemAssigned identity eliminates the need for service principal credentials"
- "Role assignments grant least-privilege access (AcrPull, Key Vault Secrets User)"
- "Remote state enables team collaboration and prevents state conflicts"

---

## Deliverable #3: Infrastructure Pipeline

**Location:** `azure-pipelines-iac.yml`

**What It Does:**
- Automates infrastructure provisioning with Terraform
- Includes manual approval gate before applying changes
- Runs on self-hosted agent pool

**Pipeline Stages:**
1. **Azure Login** - Validates Azure credentials
2. **Install Terraform** - Idempotent installation (checks if exists)
3. **Terraform Init** - Initializes backend and downloads providers
4. **Terraform Plan** - Generates execution plan with tfvars
5. **Manual Approval** - Wait for human review before apply
6. **Terraform Apply** - Provisions infrastructure

**Key Features:**
- Trigger: Only on changes to `terraform/*` folder on master branch
- Self-hosted agent: `az-agentpool`
- Explicit tfvars usage for transparency
- Manual approval for safety

**Interview Talking Points:**
- "The pipeline only triggers when infrastructure code changes"
- "Manual approval prevents accidental infrastructure changes"
- "Idempotent Terraform installation supports clean agents"
- "The plan is saved and used by apply to ensure consistency"

---

## Deliverable #4: Deployment Pipeline

**Location:** `azure-pipelines-cd.yml`

**What It Does:**
- Deploys application to AKS using Helm
- Supports runtime parameters for flexibility
- Includes post-deployment validation

**Pipeline Stages:**
1. **Checkout** - Retrieves source code (Helm chart)
2. **Install Helm** - Idempotent installation
3. **Get AKS Credentials** - Authenticates to Kubernetes cluster
4. **Helm Deploy** - Upgrades/installs application with parameters
5. **Post-Deployment Validation** - Checks rollout status

**Runtime Parameters:**
- Resource Group Name
- AKS Cluster Name
- ACR Login Server
- Image Tag (build number)

**Key Features:**
- Manual trigger (no automatic deployments)
- Runtime parameters for multi-environment support
- Build number as image tag (not 'latest')
- Rollout status check with 300s timeout

**Interview Talking Points:**
- "Runtime parameters allow deploying to different environments without code changes"
- "Using build numbers as tags ensures traceability and rollback capability"
- "Post-deployment validation confirms the deployment succeeded"
- "Manual trigger gives control over when releases happen"

---

## Security Implementation

**Key Security Features:**

1. **Managed Identity**
   - AKS uses SystemAssigned identity (no credentials to manage)
   - Eliminates service principal credential rotation

2. **Role-Based Access Control (RBAC)**
   - AKS → ACR: AcrPull role (pull images only)
   - AKS → Key Vault: Key Vault Secrets User role (read secrets only)
   - Least-privilege principle

3. **Key Vault Integration**
   - Azure Key Vault CSI driver installed automatically
   - Secrets mounted as volumes in pods (not environment variables)
   - No secrets hardcoded in code or configuration

4. **Service Connection Authentication**
   - Pipelines use Azure DevOps service connections
   - No credentials in YAML files
   - Centralized credential management

5. **Remote State Security**
   - Terraform state in Azure Storage (encrypted at rest)
   - State locking prevents concurrent modifications
   - No sensitive data in version control

**Interview Talking Points:**
- "I followed the principle of least privilege for all role assignments"
- "Managed identities eliminate credential management overhead"
- "The CSI driver provides secure, native Kubernetes secret access"
- "Remote state is encrypted and supports team collaboration"

---

## DevOps Best Practices Demonstrated

1. **Infrastructure as Code**
   - All infrastructure defined in Terraform
   - Version controlled and peer-reviewable
   - Reproducible environments

2. **GitOps Workflow**
   - IaC pipeline triggers on terraform/* changes
   - Source of truth in Git
   - Automated, auditable deployments

3. **Modular Design**
   - Terraform modules for reusability
   - Helm chart with configurable values
   - Separation of concerns

4. **Pipeline as Code**
   - YAML-based pipelines in version control
   - Declarative, reviewable, repeatable

5. **Immutable Infrastructure**
   - Image tags based on build numbers
   - No in-place modifications
   - Enables rollback

6. **Validation Gates**
   - Manual approval before infrastructure changes
   - Post-deployment health checks
   - Fail-fast approach

**Interview Talking Points:**
- "Everything is code - infrastructure, pipelines, and application config"
- "The modular design makes it easy to add new environments or services"
- "Using build numbers as tags supports immutable deployments and rollbacks"
- "Manual approval gates add a human checkpoint for critical changes"

---

## Technical Decisions & Justifications

### Why Helm?
- Industry-standard Kubernetes package manager
- Templating and parameterization
- Dependency management (Redis subchart)
- Versioning and rollback support

### Why Terraform Modules?
- Reusability across environments
- Clear separation of concerns
- Easier testing and maintenance
- Follows DRY principle

### Why Remote State?
- Team collaboration
- State locking (prevents conflicts)
- Encrypted and durable
- Supports CI/CD workflows

### Why Self-Hosted Agent?
- Free tier doesn't support Microsoft-hosted agents
- Unlimited build minutes
- Pre-installed tools (faster builds)
- Full control over environment

### Why SystemAssigned Identity?
- No credential management
- Automatic rotation
- Azure-native integration
- Follows Azure best practices

### Why Manual Trigger for CD Pipeline?
- Controlled deployments
- Prevent accidental releases
- Allows testing in staging first
- Common for production environments

---

## Deployment Workflow Summary

**One-Time Setup:**
1. Setup self-hosted agent pool (AGENT-SETUP-MANUAL.md)
2. Create service connection in Azure DevOps
3. Run bootstrap script for remote state storage
4. Update configuration (service connection, tenant ID, backend)

**Infrastructure Deployment:**
1. Push changes to terraform/* folder on master branch
2. Pipeline automatically triggers
3. Terraform plan is generated
4. Approve manually
5. Infrastructure is provisioned
6. Outputs are available for application deployment

**Application Deployment:**
1. Manually trigger CD pipeline
2. Provide runtime parameters (RG, AKS name, ACR, image tag)
3. Helm deploys/upgrades application
4. Validation confirms successful deployment
5. Application is accessible via LoadBalancer IP

---

## Interview Preparation - Key Talking Points

### Opening Statement
"I've built a complete DevSecOps solution for deploying a microservices application on Azure Kubernetes Service. The solution includes Infrastructure as Code using Terraform modules, secure CI/CD pipelines in Azure DevOps, and containerized application deployment using Helm. Everything follows security best practices with managed identities, RBAC, and automated secret management."

### Technical Depth Areas
1. **Terraform Modules**: Explain modular design and reusability
2. **Helm Charts**: Discuss templating and dependency management
3. **Pipeline Stages**: Walk through IaC and CD workflows
4. **Security**: Managed identity, RBAC, Key Vault CSI driver
5. **DevOps Practices**: GitOps, IaC, immutable infrastructure

### Expected Questions & Answers

**Q: Why did you use Terraform modules?**
A: "Modules promote reusability and maintainability. Each Azure service has its own module, making it easy to update, test, or reuse in different environments. It also follows the DRY principle and improves code organization."

**Q: How do you handle secrets?**
A: "I use Azure Key Vault with the CSI driver for Kubernetes. Secrets are mounted as volumes in pods, not exposed as environment variables. The AKS cluster has a managed identity with Key Vault Secrets User role for secure, native access."

**Q: Why manual approval in the pipeline?**
A: "Manual approval adds a human checkpoint before infrastructure changes. It allows reviewing the Terraform plan output, catching potential issues, and preventing accidental or unauthorized changes to production infrastructure."

**Q: How do you ensure deployments are traceable?**
A: "I use build numbers as image tags instead of 'latest'. Each deployment is tied to a specific build, making it easy to track what's deployed and enabling quick rollbacks if needed."

**Q: What happens if the state file is corrupted?**
A: "The state is stored in Azure Storage with encryption and versioning enabled. Azure Storage provides durability and the ability to recover previous versions. State locking prevents concurrent modifications that could corrupt the state."

**Q: How would you add a new environment (e.g., staging)?**
A: "I would create a new tfvars file (e.g., staging.tfvars), use workspace or separate state files, and run the pipeline with the new configuration. The modular design makes it easy to spin up identical environments with different parameters."

---

## Files to Present During Interview

**Core Deliverables:**
1. `azure-vote-chart/` - Show Chart.yaml, values.yaml, and key templates
2. `terraform/main.tf` - Explain modular structure and resources
3. `terraform/modules/` - Show one module (e.g., AKS) in detail
4. `azure-pipelines-iac.yml` - Walk through stages
5. `azure-pipelines-cd.yml` - Explain runtime parameters

**Supporting Documentation:**
6. `terraform/outputs.tf` - Show how outputs feed into CD pipeline
7. `terraform/backend.tf` - Explain remote state setup
8. `DEPLOYMENT-CHECKLIST.txt` - Deployment workflow
9. Architecture diagram (draw or show ASCII version)

**Optional Deep Dive:**
10. `terraform/modules/aks/main.tf` - Show managed identity configuration
11. `azure-vote-chart/templates/deployment.yaml` - Show Helm templating
12. Role assignment resources in main.tf - Explain RBAC

---

## Success Criteria Met

✅ **Helm chart created** for azure-vote application with Redis dependency
✅ **Modular Terraform IaC** with separate modules for each Azure service
✅ **AKS cluster provisioned** with SystemAssigned managed identity
✅ **ACR integrated** with AKS via role assignment (AcrPull)
✅ **Key Vault configured** with CSI driver for secret management
✅ **Remote state** implemented with Azure Storage backend
✅ **IaC pipeline** with Terraform init/plan/apply and manual approval
✅ **CD pipeline** with Helm deployment and validation
✅ **Security best practices** (managed identity, RBAC, no hardcoded secrets)
✅ **Documentation** complete and assessment-ready

---

## Additional Notes

- All code is production-ready and follows Azure best practices
- The solution is fully modular and can be extended for multi-environment setups
- Security is implemented at every layer (identity, RBAC, secrets)
- Pipelines are declarative and version-controlled
- Remote state enables team collaboration
- Self-hosted agent provides unlimited build minutes for free tier

---

**End of Documentation Summary**
