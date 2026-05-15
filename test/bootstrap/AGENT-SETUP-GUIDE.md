# Azure DevOps Self-Hosted Agent Setup Guide

## Overview
This script installs and configures an Azure DevOps self-hosted agent on a Linux VM (Ubuntu/Debian).

## Prerequisites

1. **Linux VM** (Ubuntu 20.04 or later recommended)
2. **Azure DevOps Organization** with a project
3. **Personal Access Token (PAT)** with Agent Pools (read, manage) permissions

## Step 1: Create a Personal Access Token (PAT)

1. Go to Azure DevOps: https://dev.azure.com/YOUR_ORGANIZATION
2. Click on **User Settings** (top right) > **Personal Access Tokens**
3. Click **+ New Token**
4. Set:
   - Name: `Agent Pool Token`
   - Organization: Select your organization
   - Expiration: 90 days (or as needed)
   - Scopes: **Agent Pools (read, manage)**
5. Click **Create**
6. **Copy the token** (you won't see it again!)

## Step 2: Create Agent Pool in Azure DevOps

1. Go to **Project Settings** > **Agent pools**
2. Click **Add pool**
3. Select **Self-hosted**
4. Name: `az-agentpool` (or match your pipeline configuration)
5. Click **Create**

## Step 3: Update the Script

Edit `setup-azdo-agent.sh` and update these variables:

```bash
AZDO_URL="https://dev.azure.com/YOUR_ORGANIZATION"  # Your Azure DevOps org URL
AZDO_TOKEN="YOUR_PERSONAL_ACCESS_TOKEN"              # PAT from Step 1
AGENT_POOL="az-agentpool"                            # Pool name from Step 2
```

## Step 4: Run the Script on Your Linux VM

```bash
# Copy the script to your VM
scp setup-azdo-agent.sh user@vm-ip:~/

# SSH to the VM
ssh user@vm-ip

# Make the script executable
chmod +x setup-azdo-agent.sh

# Run the script
bash setup-azdo-agent.sh
```

## Step 5: Verify Agent Registration

1. Go to Azure DevOps > **Project Settings** > **Agent pools** > **az-agentpool**
2. Click on the **Agents** tab
3. You should see your agent listed as **Online**

## Managing the Agent

### Check agent status
```bash
cd ~/azdo-agent
sudo ./svc.sh status
```

### Stop the agent
```bash
cd ~/azdo-agent
sudo ./svc.sh stop
```

### Start the agent
```bash
cd ~/azdo-agent
sudo ./svc.sh start
```

### View logs
```bash
cd ~/azdo-agent
tail -f _diag/*.log
```

### Uninstall the agent
```bash
cd ~/azdo-agent
sudo ./svc.sh stop
sudo ./svc.sh uninstall
./config.sh remove --auth pat --token YOUR_PAT
```

## Additional Tools to Install on Agent (Optional)

For your AKS deployment pipelines, you may need:

### Install Azure CLI
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Install kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Install Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Install Terraform
```bash
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Install Docker (if needed for builds)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

## Troubleshooting

### Agent not showing as online
- Check if the service is running: `sudo ./svc.sh status`
- Check logs: `tail -f _diag/*.log`
- Verify PAT has correct permissions
- Verify AZDO_URL is correct

### Pipeline fails with permission errors
- Ensure the agent user has sudo permissions (if needed)
- Install required tools (Azure CLI, kubectl, Helm, Terraform)

### Agent disconnects frequently
- Check VM network connectivity
- Check VM resources (CPU, memory)
- Review agent logs for errors

## Security Best Practices

1. **Use a dedicated service account** for the agent (not root)
2. **Rotate PATs regularly** (before expiration)
3. **Limit PAT scope** to only Agent Pools permissions
4. **Restrict agent pool access** to specific projects/pipelines
5. **Keep the agent VM updated** with security patches

## References

- [Azure DevOps Agent Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent)
- [Agent Releases](https://github.com/microsoft/azure-pipelines-agent/releases)
