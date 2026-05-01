# Destroy Guide — MWD Oil Co. Azure DR Reference Architecture

> Use this guide to safely remove all deployed resources after testing.

---

## Before You Destroy

1. Confirm there is no production workload using these resources
2. Export any Log Analytics data you want to retain
3. Confirm Recovery Vault has no protected items with retention locks
4. Note any resources you may have created manually in the portal (Terraform will not destroy those)

---

## Step 1 — Destroy Primary Environment

```bash
cd environments/primary

# Preview what will be destroyed
terraform plan -destroy

# Destroy all primary resources
terraform destroy
```

When prompted, type `yes` to confirm.

---

## Step 2 — Destroy DR Environment (if enabled)

```bash
cd ../dr

# Only necessary if you enabled DR resources (count = 1)
terraform plan -destroy
terraform destroy
```

---

## Step 3 — Verify in Azure Portal

1. Navigate to **Resource Groups** in the Azure Portal
2. Confirm the following resource groups no longer exist:
   - `rg-mwd-hub-primary`
   - `rg-mwd-hq-primary`
   - `rg-mwd-corpuschristi-primary`
   - `rg-mwd-midland-primary`
   - `rg-mwd-drillsite-a-primary`
   - `rg-mwd-drillsite-b-primary`
   - `rg-mwd-hub-dr` (if DR was enabled)
3. Navigate to **Log Analytics Workspaces** and confirm deletion
4. Navigate to **Recovery Services Vaults** and confirm deletion

> ⚠️ Recovery Services Vaults with backup data may require manual deletion of backup items before the vault can be removed.

---

## Step 4 — Clean Local State

After confirming all resources are destroyed:

```bash
# Remove local state files (they are no longer valid)
rm environments/primary/terraform.tfstate
rm environments/primary/terraform.tfstate.backup
rm environments/dr/terraform.tfstate
rm environments/dr/terraform.tfstate.backup
```

> Do not commit state files to Git under any circumstances.

---

## Handling Stuck Resources

### Recovery Services Vault Won't Delete

If the vault has backup items, you must remove them first:

1. In Azure Portal → Recovery Services Vault → **Backup Items**
2. Stop backup and delete backup data for each item
3. Wait for soft-delete retention to clear (may take up to 14 days unless soft-delete is disabled)
4. Then re-run `terraform destroy`

### Resource Group Stuck in "Deleting" State

This occasionally happens with VNet peerings. Wait 5–10 minutes and check again. If stuck:

```bash
# Force delete via Azure CLI
az group delete --name rg-mwd-hub-primary --yes --no-wait
```

---

## Cost Verification After Destroy

After destroying:
1. Check Azure Cost Management for any lingering charges
2. Verify no Public IP addresses remain (they are billed even when unattached)
3. Check for orphaned managed disks in the subscription

---

*When in doubt, check the portal. Terraform destroy is reliable but always verify manually for lab environments.*
