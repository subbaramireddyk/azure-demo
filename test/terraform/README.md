# Terraform AKS DevSecOps Infrastructure

This Terraform configuration provisions a secure, production-ready Azure Kubernetes Service (AKS) environment with:
- Azure Container Registry (ACR)
- Azure Key Vault
- Azure Storage Account
- Azure Key Vault CSI driver (via Helm)
- Role assignments for AKS to pull images from ACR and access Key Vault secrets

## Usage

1. **Configure variables:**
   - Edit `terraform.tfvars` with your values (resource names, location, tenant_id, etc.)

2. **Initialize Terraform:**
   ```sh
   terraform init
   ```

3. **Plan the deployment:**
   ```sh
   terraform plan
   ```

4. **Apply the deployment:**
   ```sh
   terraform apply
   ```

## Key Variables
- `resource_group_name`: Name for the resource group
- `location`: Azure region (e.g., eastus)
- `acr_name`: Azure Container Registry name
- `aks_name`: AKS cluster name
- `keyvault_name`: Key Vault name
- `storage_name`: Storage account name
- `tenant_id`: Azure AD tenant ID

## Outputs
- AKS cluster name, resource group, and kubeconfig
- ACR login server and resource ID
- Key Vault URI and resource ID
- Storage account name and resource ID

## Notes
- The AKS cluster is granted permissions to pull images from ACR and access Key Vault secrets.
- The Azure Key Vault CSI driver is installed automatically using the Helm provider.
- Application deployment (Helm charts/manifests) should be handled in a separate pipeline.

---

**For more details, see each module's variables.tf.**
