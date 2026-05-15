#!/bin/bash
# Run with: bash setup-azdo-agent.sh

# Azure DevOps Self-Hosted Agent Setup Script
# This script installs and configures an Azure DevOps agent on a Linux VM

echo "========================================="
echo "Azure DevOps Agent Setup"
echo "========================================="

# Variables - UPDATE THESE BEFORE RUNNING
AZDO_URL="https://dev.azure.com/YOUR_ORGANIZATION"  # e.g., https://dev.azure.com/myorg
AZDO_TOKEN="YOUR_PERSONAL_ACCESS_TOKEN"              # Generate from Azure DevOps
AGENT_POOL="az-agentpool"                            # Agent pool name
AGENT_NAME="agent-$(hostname)"                       # Agent name (uses hostname)
WORK_FOLDER="_work"

# Download URL for the latest agent
AGENT_VERSION="3.236.1"  # Update to latest version from https://github.com/microsoft/azure-pipelines-agent/releases
AGENT_URL="https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"

echo ""
echo "Step 1: Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl wget unzip libicu-dev

echo ""
echo "Step 2: Creating agent directory..."
mkdir -p ~/azdo-agent
cd ~/azdo-agent

echo ""
echo "Step 3: Downloading Azure DevOps agent..."
wget -q $AGENT_URL -O agent.tar.gz

echo ""
echo "Step 4: Extracting agent..."
tar -xzf agent.tar.gz
rm agent.tar.gz

echo ""
echo "Step 5: Installing dependencies..."
sudo ./bin/installdependencies.sh

echo ""
echo "Step 6: Configuring agent..."
./config.sh \
  --unattended \
  --url "$AZDO_URL" \
  --auth pat \
  --token "$AZDO_TOKEN" \
  --pool "$AGENT_POOL" \
  --agent "$AGENT_NAME" \
  --work "$WORK_FOLDER" \
  --replace \
  --acceptTeeEula

echo ""
echo "Step 7: Installing agent as a service..."
sudo ./svc.sh install

echo ""
echo "Step 8: Starting agent service..."
sudo ./svc.sh start

echo ""
echo "========================================="
echo "Azure DevOps Agent Setup Complete!"
echo "========================================="
echo "Agent Name: $AGENT_NAME"
echo "Agent Pool: $AGENT_POOL"
echo "Organization: $AZDO_URL"
echo ""
echo "Check agent status:"
echo "  sudo ./svc.sh status"
echo ""
echo "Stop agent:"
echo "  sudo ./svc.sh stop"
echo ""
echo "View logs:"
echo "  tail -f _diag/*.log"
echo "========================================="
