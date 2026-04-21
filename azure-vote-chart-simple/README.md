# Azure Vote Helm Chart - Simple Version

A simplified Helm chart for deploying Azure Vote App to AKS with Azure Key Vault integration.

## Prerequisites

- AKS cluster with Workload Identity enabled
- Azure Key Vault with secrets: `redis-password` and `secretKey`
- ACR with the azure-vote image
- CSI Secret Store driver installed on AKS

## Quick Start

### 1. Install Redis dependency
```bash
helm dependency update
```

### 2. Update values.yaml with your settings
```yaml
image:
  repository: <your-acr>.azurecr.io/azure-vote
  
keyVault:
  name: <your-keyvault-name>
  tenantId: <your-tenant-id>
  clientId: <your-workload-identity-client-id>
```

### 3. Install the chart
```bash
helm install azure-vote . --namespace voting-app --create-namespace
```

## What's Included

- **Deployment**: Azure Vote app with 2 replicas
- **Service**: LoadBalancer exposing port 80
- **ServiceAccount**: With Workload Identity annotations
- **SecretProviderClass**: Fetches secrets from Azure Key Vault
- **Redis**: Bitnami Redis chart as dependency

## Architecture

```
azure-vote (Frontend) → Redis (Backend)
         ↓
   Azure Key Vault (Secrets)
```

## Required Key Vault Secrets

1. `redis-password` - Password for Redis connection
2. `secretKey` - Application secret key

## Customization

Edit [values.yaml](values.yaml) to change:
- Replica count
- Service type (LoadBalancer/ClusterIP)
- App title and voting options
- Image tag

## Testing

```bash
# Get service IP
kubectl get svc azure-vote -n voting-app

# Check pods
kubectl get pods -n voting-app

# View logs
kubectl logs -l app=azure-vote -n voting-app
```

## Cleanup

```bash
helm uninstall azure-vote -n voting-app
```
