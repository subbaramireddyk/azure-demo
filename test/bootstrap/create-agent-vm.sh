#!/bin/bash
# Run with: bash create-agent-vm.sh
# Creates an Azure VM and automatically sets up Azure DevOps agent with required tools

echo "========================================="
echo "Azure VM + DevOps Agent Setup"
echo "========================================="

# Variables - UPDATE THESE BEFORE RUNNING
RESOURCE_GROUP="rg-azdo-agent"
LOCATION="eastus"
VM_NAME="vm-azdo-agent"
VM_SIZE="Standard_B2s"  # 2 vCPU, 4GB RAM
VM_IMAGE="Ubuntu2204"   # Ubuntu 22.04 LTS
ADMIN_USERNAME="azureuser"

# Azure DevOps Configuration - UPDATE THESE
AZDO_URL="https://dev.azure.com/YOUR_ORGANIZATION"
AZDO_TOKEN="YOUR_PERSONAL_ACCESS_TOKEN"
AGENT_POOL="az-agentpool"

echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  VM Name: $VM_NAME"
echo "  VM Size: $VM_SIZE"
echo "  Admin User: $ADMIN_USERNAME"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "Step 1: Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo ""
echo "Step 2: Generating cloud-init script..."
cat > cloud-init.txt <<'EOF'
#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl
  - wget
  - unzip
  - git
  - libicu-dev
  - jq

runcmd:
  # Install Azure CLI
  - curl -sL https://aka.ms/InstallAzureCLIDeb | bash

  # Install kubectl
  - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  - install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  - rm kubectl

  # Install Helm
  - curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  # Install Terraform
  - wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
  - unzip -q terraform_1.6.6_linux_amd64.zip
  - mv terraform /usr/local/bin/
  - rm terraform_1.6.6_linux_amd64.zip

  # Install Docker
  - curl -fsSL https://get.docker.com -o get-docker.sh
  - sh get-docker.sh
  - usermod -aG docker ADMIN_USERNAME
  - rm get-docker.sh

  # Create agent directory
  - mkdir -p /home/ADMIN_USERNAME/azdo-agent
  - cd /home/ADMIN_USERNAME/azdo-agent

  # Download Azure DevOps agent
  - wget -q https://vstsagentpackage.azureedge.net/agent/3.236.1/vsts-agent-linux-x64-3.236.1.tar.gz -O agent.tar.gz
  - tar -xzf agent.tar.gz
  - rm agent.tar.gz
  - chown -R ADMIN_USERNAME:ADMIN_USERNAME /home/ADMIN_USERNAME/azdo-agent

  # Install agent dependencies
  - cd /home/ADMIN_USERNAME/azdo-agent
  - ./bin/installdependencies.sh

  # Configure agent as ADMIN_USERNAME
  - sudo -u ADMIN_USERNAME ./config.sh --unattended --url "AZDO_URL" --auth pat --token "AZDO_TOKEN" --pool "AGENT_POOL" --agent "$HOSTNAME" --work "_work" --replace --acceptTeeEula

  # Install and start agent service
  - ./svc.sh install ADMIN_USERNAME
  - ./svc.sh start

  # Log completion
  - echo "Azure DevOps agent setup completed at $(date)" >> /var/log/agent-setup.log

write_files:
  - path: /etc/motd
    content: |
      ========================================
      Azure DevOps Build Agent
      ========================================
      Installed tools:
        - Azure CLI
        - kubectl
        - Helm
        - Terraform
        - Docker
        - Azure DevOps Agent

      Agent status: sudo /home/ADMIN_USERNAME/azdo-agent/svc.sh status
      Agent logs: tail -f /home/ADMIN_USERNAME/azdo-agent/_diag/*.log
      ========================================
EOF

# Replace placeholders in cloud-init
sed -i "s|ADMIN_USERNAME|$ADMIN_USERNAME|g" cloud-init.txt
sed -i "s|AZDO_URL|$AZDO_URL|g" cloud-init.txt
sed -i "s|AZDO_TOKEN|$AZDO_TOKEN|g" cloud-init.txt
sed -i "s|AGENT_POOL|$AGENT_POOL|g" cloud-init.txt

echo ""
echo "Step 3: Creating VM with cloud-init..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $VM_IMAGE \
  --size $VM_SIZE \
  --admin-username $ADMIN_USERNAME \
  --generate-ssh-keys \
  --custom-data cloud-init.txt \
  --public-ip-sku Standard \
  --output table

echo ""
echo "Step 4: Getting VM IP address..."
VM_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

echo ""
echo "========================================="
echo "VM Creation Complete!"
echo "========================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "VM Name: $VM_NAME"
echo "VM IP: $VM_IP"
echo "Admin User: $ADMIN_USERNAME"
echo ""
echo "SSH to VM:"
echo "  ssh $ADMIN_USERNAME@$VM_IP"
echo ""
echo "Note: Agent setup is running in the background."
echo "Wait 5-10 minutes for cloud-init to complete."
echo ""
echo "Check cloud-init progress:"
echo "  ssh $ADMIN_USERNAME@$VM_IP 'tail -f /var/log/cloud-init-output.log'"
echo ""
echo "Verify agent is online:"
echo "  Azure DevOps > Project Settings > Agent pools > $AGENT_POOL"
echo "========================================="

# Clean up cloud-init file
rm cloud-init.txt
