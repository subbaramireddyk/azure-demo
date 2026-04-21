#!/bin/bash

# Variables (edit as needed or pass as arguments)
RESOURCE_GROUP="rg-tfstate-demo"
LOCATION="eastus"
STORAGE_ACCOUNT="sttfstatedemo$RANDOM"
CONTAINER_NAME="tfstate"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account (must be globally unique)
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --account-key $ACCOUNT_KEY

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container Name:  $CONTAINER_NAME"
echo "Resource Group:  $RESOURCE_GROUP"
echo "Location:        $LOCATION"
echo "Account Key:     $ACCOUNT_KEY"
