# Azure VM for Azure DevOps Agent - Quick Setup

## What This Script Does

The `create-agent-vm.sh` script automatically:
1. Creates an Azure resource group
2. Creates an Ubuntu VM
3. Installs required tools (Azure CLI, kubectl, Helm, Terraform, Docker)
4. Downloads and configures Azure DevOps agent
5. Registers agent with your Azure DevOps organization
6. Starts the agent as a service

**Everything happens automatically via cloud-init!**

## Prerequisites

1. Azure CLI installed and logged in:
   ```bash
   az login
   ```

2. Azure DevOps Personal Access Token (PAT):
   - Go to: https://dev.azure.com/YOUR_ORG
   - User Settings > Personal Access Tokens > New Token
   - Scopes: **Agent Pools (read, manage)**
   - Copy the token

3. Agent pool created in Azure DevOps:
   - Project Settings > Agent pools > Add pool
   - Type: Self-hosted
   - Name: `az-agentpool`

## Step 1: Update Script Variables

Edit `create-agent-vm.sh` and update these lines (around line 15-20):

```bash
AZDO_URL="https://dev.azure.com/YOUR_ORGANIZATION"  # Your Azure DevOps org
AZDO_TOKEN="YOUR_PERSONAL_ACCESS_TOKEN"              # PAT from prerequisites
AGENT_POOL="az-agentpool"                            # Your agent pool name
```

Optional VM configuration:
```bash
RESOURCE_GROUP="rg-azdo-agent"  # Change if needed
LOCATION="eastus"                # Change region if needed
VM_SIZE="Standard_B2s"           # 2vCPU, 4GB RAM (good for demos)
```

## Step 2: Run the Script

```bash
chmod +x create-agent-vm.sh
bash create-agent-vm.sh
```

## Step 3: Wait for Setup to Complete

The VM creation takes ~2 minutes, but cloud-init setup takes **5-10 minutes**.

Monitor progress:
```bash
# Get VM IP from script output, then:
ssh azureuser@<VM_IP> 'tail -f /var/log/cloud-init-output.log'
```

## Step 4: Verify Agent is Online

1. Go to Azure DevOps: **Project Settings** > **Agent pools** > **az-agentpool** > **Agents** tab
2. You should see your agent listed as **Online**
3. Agent name will be the VM hostname (e.g., `vm-azdo-agent`)

## Tools Installed on the VM

The agent VM comes pre-configured with:
- Azure CLI
- kubectl
- Helm
- Terraform
- Docker
- Git, curl, wget, jq

## SSH to the VM

```bash
# Use the IP from the script output
ssh azureuser@<VM_IP>
```

## Useful Commands on the VM

### Check agent status
```bash
sudo /home/azureuser/azdo-agent/svc.sh status
```

### View agent logs
```bash
tail -f /home/azureuser/azdo-agent/_diag/*.log
```

### Check cloud-init logs
```bash
tail -f /var/log/cloud-init-output.log
```

## Cost Estimation

**Standard_B2s VM (2 vCPU, 4GB RAM):**
- ~$35/month if running 24/7
- **Recommendation:** Stop when not in use to save costs

### Stop VM when not needed
```bash
az vm deallocate --resource-group rg-azdo-agent --name vm-azdo-agent
```

### Start VM when needed
```bash
az vm start --resource-group rg-azdo-agent --name vm-azdo-agent
```

**Note:** Agent will auto-start when VM boots!

## Cleanup (Delete Everything)

```bash
az group delete --name rg-azdo-agent --yes --no-wait
```

## Troubleshooting

### Agent not showing online after 10 minutes
```bash
# SSH to VM and check cloud-init status
ssh azureuser@<VM_IP>
cloud-init status

# Check for errors in cloud-init logs
tail -100 /var/log/cloud-init-output.log

# Manually check agent status
cd /home/azureuser/azdo-agent
sudo ./svc.sh status
```

### Pipeline fails with permission errors
```bash
# Verify tools are installed
az --version
kubectl version --client
helm version
terraform version
docker --version
```

## Alternative: Manual Setup

If you prefer manual setup instead of cloud-init, use the original `setup-azdo-agent.sh` script:
1. Create a VM manually (Azure Portal or CLI)
2. SSH to the VM
3. Run: `bash setup-azdo-agent.sh`

---

**That's it! Your Azure DevOps agent is ready to run pipelines with unlimited minutes.**
