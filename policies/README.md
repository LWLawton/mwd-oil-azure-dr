# Azure Policy Definitions
## MWD Oil Co. — Reference Architecture

This directory contains Azure Policy definition JSON files for MWD Oil Co.'s governance baseline.

---

## Policies Included

| File | Policy Name | Effect | Purpose |
|------|-------------|--------|---------|
| `allowed-vm-skus.json` | Allowed VM SKUs | Deny | Restrict VM sizes to approved (cost-controlled) SKUs |
| `require-tags.json` | Require Resource Tags | Audit/Deny | Enforce project, environment, and owner tags |
| `deny-public-ip.json` | Deny Public IP on VMs | Deny | Prevent direct public IP assignment to VMs |
| `require-tls.json` | Enforce TLS 1.2 Minimum | Audit | Ensure storage accounts use minimum TLS 1.2 |

---

## How to Apply Policies

Policies are applied via Azure Policy Assignments at subscription or resource group scope.

```bash
# Create a policy definition
az policy definition create \
  --name "mwd-allowed-vm-skus" \
  --display-name "MWD Allowed VM SKUs" \
  --description "Restricts VM deployment to approved SKUs" \
  --rules policies/allowed-vm-skus.json \
  --mode All

# Assign the policy at subscription scope
az policy assignment create \
  --name "mwd-allowed-vm-skus-assignment" \
  --scope /subscriptions/REPLACE_WITH_SUBSCRIPTION_ID \
  --policy "mwd-allowed-vm-skus"
```

---

## Policy Design Principles

1. **Audit first, Deny after validation** — Start new policies in Audit mode before switching to Deny
2. **Exemptions documented** — Any policy exemption requires a ticket and CISO approval
3. **OT resource groups** — Apply less restrictive policies to OT resource groups where operational requirements differ from corporate IT
