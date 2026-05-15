# Azure DevOps Self-Hosted Agent Pool - Manual Setup Guide

## Overview
This guide documents the manual setup process for configuring a self-hosted agent pool in Azure DevOps to run the infrastructure and deployment pipelines.

## Prerequisites
- Linux VM (Ubuntu 20.04 or 22.04 recommended)
- Azure DevOps organization with a project
- Internet connectivity on the VM

---

## Step 1: Create Agent Pool in Azure DevOps

1. Navigate to Azure DevOps project
2. Click **Project Settings** (bottom left corner)
3. Under **Pipelines**, click **Agent pools**
4. Click **Add pool** button
5. Configure the pool:
   - Pool type: **Self-hosted**
   - Name: `az-agentpool`
   - ✓ Grant access permission to all pipelines
6. Click **Create**

---

## Step 2: Create Personal Access Token (PAT)

1. Click on **User Settings** icon (top right corner)
2. Select **Personal Access Tokens**
3. Click **+ New Token**
4. Configure the token:
   - Name: `Agent Pool Token`
   - Organization: Select your organization
   - Expiration: 90 days (or as required)
   - Scopes: **Agent Pools (read, manage)**
5. Click **Create**
6. **Copy the token immediately** (it won't be shown again)

---

## Step 3: Prepare Linux VM

### Option A: Using Azure VM
```bash
# Create resource group
az group create --name rg-azdo-agent --location eastus

# Create Ubuntu VM
az vm create \
  --resource-group rg-azdo-agent \
  --name vm-azdo-agent \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys

# Get VM IP
az vm show -d -g rg-azdo-agent -n vm-azdo-agent --query publicIps -o tsv

# SSH to the VM
ssh azureuser@<VM_IP>
```

### Option B: Using Existing Linux VM
```bash
# SSH to your existing Linux VM
ssh user@your-vm-ip
```

---

## Step 4: Install Azure DevOps Agent on VM

### 4.1: Create Agent Directory
```bash
mkdir ~/azdo-agent && cd ~/azdo-agent
```

### 4.2: Download Agent Package
```bash
wget https://vstsagentpackage.azureedge.net/agent/3.236.1/vsts-agent-linux-x64-3.236.1.tar.gz
tar xzf vsts-agent-linux-x64-3.236.1.tar.gz
```

### 4.3: Configure Agent
```bash
./config.sh
```

**Answer the prompts as follows:**
```
Enter server URL > https://dev.azure.com/YOUR_ORGANIZATION
Enter authentication type (press enter for PAT) > [Press Enter]
Enter personal access token > [Paste your PAT from Step 2]
Enter agent pool (press enter for default) > az-agentpool
Enter agent name (press enter for vm-azdo-agent) > [Press Enter]
Enter work folder (press enter for _work) > [Press Enter]
```

### 4.4: Install Agent as a Service
```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

---

## Step 5: Verify Agent Status

### In Azure DevOps:
1. Go to **Project Settings** > **Agent pools**
2. Click on **az-agentpool**
3. Click **Agents** tab
4. Verify your agent shows as **Online** with a green status

### On the VM:
```bash
# Check service status
sudo ./svc.sh status

# View agent logs
tail -f ~/azdo-agent/_diag/*.log
```

---

## Step 6: Install Required Tools on Agent

For the pipelines to work, install these tools on the agent VM:

### Azure CLI
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```

### kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

### Terraform
```bash
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

---

## Agent Management Commands

### Check Agent Status
```bash
cd ~/azdo-agent
sudo ./svc.sh status
```

### Stop Agent
```bash
cd ~/azdo-agent
sudo ./svc.sh stop
```

### Start Agent
```bash
cd ~/azdo-agent
sudo ./svc.sh start
```

### View Logs
```bash
tail -f ~/azdo-agent/_diag/*.log
```

### Uninstall Agent
```bash
cd ~/azdo-agent
sudo ./svc.sh stop
sudo ./svc.sh uninstall
./config.sh remove --auth pat --token <YOUR_PAT>
```

---

## Troubleshooting

### Agent Not Showing Online
- Verify service is running: `sudo ./svc.sh status`
- Check logs: `tail -f ~/azdo-agent/_diag/*.log`
- Verify PAT has correct permissions (Agent Pools: read, manage)
- Verify organization URL is correct

### Pipeline Fails with "Tool Not Found"
- Verify all required tools are installed
- Check tool versions match pipeline requirements
- Ensure tools are in PATH: `which az kubectl helm terraform`

### Permission Denied Errors
- Ensure agent user has necessary permissions
- For Docker: `sudo usermod -aG docker $USER` and re-login

---

## Cost Optimization (Azure VM)

### Deallocate VM When Not in Use
```bash
az vm deallocate --resource-group rg-azdo-agent --name vm-azdo-agent
```

### Start VM When Needed
```bash
az vm start --resource-group rg-azdo-agent --name vm-azdo-agent
# Agent service will auto-start
```

### Delete Resources After Assessment
```bash
az group delete --name rg-azdo-agent --yes --no-wait
```

---

## Summary

✅ Agent pool created: `az-agentpool`
✅ Agent installed and configured on Linux VM
✅ Required tools installed (Azure CLI, kubectl, Helm, Terraform)
✅ Agent running as a service (auto-starts on boot)
✅ Agent verified as Online in Azure DevOps

**The agent is now ready to execute IaC and CD pipelines.**
