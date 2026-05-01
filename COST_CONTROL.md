# Cost Control Guide — MWD Oil Co. Azure DR Reference Architecture

> ⚠️ **READ THIS BEFORE RUNNING `terraform apply`**

---

## This Is a Reference Architecture

This Terraform project is designed as a **portfolio and reference demonstration**. It is not intended to be deployed in production without significant review, cost planning, and organizational approval.

**Do not run `terraform apply` unless you:**
1. Understand which resources will be created
2. Have reviewed estimated monthly costs
3. Have a plan to run `terraform destroy` when done
4. Are using a non-production Azure subscription

---

## What Gets Deployed by Default

When you run `terraform apply` against the **primary** environment with default settings, the following resources are created:

| Resource | Count | Estimated Monthly Cost |
|----------|-------|----------------------|
| Resource Groups | 5 | Free |
| Hub VNet | 1 | ~$0 (VNet free, peering charged) |
| Spoke VNets | 5 | ~$0 |
| VNet Peering | 5 pairs | ~$5–15 |
| NSGs | ~10 | Free |
| Linux VMs (Standard_B2s) | ~8 | ~$60–80 |
| Managed Disks (32GB) | ~8 | ~$10–15 |
| Storage Accounts (LRS) | 2 | ~$5–10 |
| Log Analytics Workspace | 1 | ~$0–30 (first 5GB/day free) |
| Recovery Services Vault | 1 | ~$0 (no protected items by default) |
| Public IPs (if enabled) | ~2 | ~$5–10 |
| **Estimated Total (Primary)** | | **~$85–160/month** |

---

## DR Resources (count = 0 by Default)

All DR environment resources are set to `count = 0` in `environments/dr/main.tf`. They **will not deploy** unless you explicitly change the count values.

To enable DR resources:
```hcl
# In environments/dr/main.tf, change:
count = 0   # DR powered down — change to 1 to enable
# to:
count = 1
```

> ⚠️ Enabling all DR resources approximately **doubles** your monthly cost.

---

## Intentionally Omitted Expensive Resources

The following resources are **not included** in this reference architecture to control cost:

| Resource | Monthly Cost | Why Omitted |
|----------|-------------|-------------|
| Azure Firewall | ~$900+ | Cost prohibitive for demo |
| ExpressRoute Circuit | ~$500+ | Requires physical provider |
| Azure Bastion (Standard) | ~$140+ | Optional, placeholder only |
| Azure DDoS Protection | ~$2,950+ | Enterprise only |
| Key Vault (HSM-backed) | ~$1,000+ | Not needed for demo |
| VM Scale Sets | Variable | Over-engineered for lab |
| Azure Dedicated Host | ~$1,400+ | Not needed |

---

## VM Size Guidance

Default VM size: `Standard_B2s` (~$30/month each)

To reduce cost further, change to `Standard_B1s` (~$8/month each):
```hcl
# In terraform.tfvars or variables:
vm_size = "Standard_B1s"
```

> Note: `Standard_B1s` has limited CPU burst — not suitable for any real workload.

---

## Storage Account Replication

Default storage replication is `LRS` (Locally Redundant Storage) for lowest cost.

For DR simulation, `GRS` (Geo-Redundant Storage) is recommended but costs ~2x:
```hcl
storage_replication_type = "GRS"
```

---

## How to Destroy All Resources

See [DESTROY_GUIDE.md](./DESTROY_GUIDE.md) for step-by-step instructions.

Quick reference:
```bash
cd environments/primary
terraform destroy

cd ../dr
terraform destroy
```

> Always verify in the Azure Portal that all resource groups have been deleted after running destroy.

---

## Remote State Cost Consideration

This project uses **local Terraform state** for demo purposes. For a team environment, remote state in Azure Blob Storage costs approximately:
- Storage: ~$0.02/GB/month (negligible)
- Operations: ~$0.004/10,000 operations (negligible)

See the backend configuration guide in `environments/primary/BACKEND_GUIDE.md`.

---

## Azure Cost Management

If you do deploy this architecture:
1. Set a **budget alert** in Azure Cost Management at $50 and $100
2. Enable **cost anomaly alerts**
3. Tag all resources with `environment = "lab"` and `project = "mwd-dr-demo"`
4. Review the Azure Pricing Calculator before applying

---

*Cost estimates are approximate and subject to change. Always verify current Azure pricing at https://azure.microsoft.com/pricing*
