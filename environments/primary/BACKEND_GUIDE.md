# Remote State Backend Configuration Guide
## MWD Oil Co. — Terraform State Management

> This project uses **local state** by default for demo/lab purposes.  
> This guide explains how to migrate to Azure Storage remote state for team use.

---

## Why Remote State?

Local Terraform state (`terraform.tfstate`) is:
- Stored on your machine only — not shared with teammates
- At risk of loss if your machine is lost
- Not suitable for CI/CD pipelines
- Not locked — concurrent applies can corrupt state

Remote state in Azure Blob Storage solves all of these.

---

## Step 1 — Create the State Storage Resources

Run these Azure CLI commands **before** configuring the backend.  
Do this once per team/subscription. Use a dedicated storage account for Terraform state only.

```bash
# Variables — replace these values
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="stmwdtfstate"        # Must be globally unique, lowercase, 3-24 chars
CONTAINER_NAME="tfstate"
LOCATION="southcentralus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT

# Enable versioning (protects state history)
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-versioning true
```

---

## Step 2 — Configure the Backend Block

In `environments/primary/main.tf`, uncomment and update the backend block:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stmwdtfstate"      # Replace with your storage account name
    container_name       = "tfstate"
    key                  = "mwd-primary.tfstate"
  }
}
```

For the DR environment, use a different key:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stmwdtfstate"
    container_name       = "tfstate"
    key                  = "mwd-dr.tfstate"
  }
}
```

---

## Step 3 — Migrate Existing Local State

If you already have local state:

```bash
cd environments/primary

# Re-initialize with the new backend
terraform init

# Terraform will prompt:
# "Do you want to copy existing state to the new backend? (yes/no)"
# Type: yes
```

---

## Step 4 — Lock the State Storage Account

After setup, restrict access to the state storage account:

```bash
# Get your current IP
MY_IP=$(curl -s https://ifconfig.me)

# Add network rule (allow only your IP and Azure services)
az storage account network-rule add \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --ip-address $MY_IP

# Set default action to deny
az storage account update \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --default-action Deny
```

---

## Authentication for CI/CD

For GitHub Actions, set these secrets in your repository:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

Use a service principal with `Contributor` on the infrastructure subscription and `Storage Blob Data Contributor` on the state storage account.

> **Never** commit service principal credentials to source control.

---

## State File Naming Convention

| Environment | State Key |
|-------------|-----------|
| Primary | `mwd-primary.tfstate` |
| DR | `mwd-dr.tfstate` |

---

*Remote state setup is a one-time operation. Once configured, all team members and pipelines share the same state.*
