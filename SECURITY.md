# Security Policy — MWD Oil Co. Azure DR Reference Architecture

> **This is a fictional portfolio project.** No real infrastructure, credentials, or company data is present in this repository.

---

## Reporting a Security Issue

If you discover a security vulnerability or exposed credential in this repository, please open a GitHub Issue or contact the repository owner directly. Do not create a public pull request disclosing sensitive findings.

---

## What This Repo Does and Does Not Contain

### ✅ Safe to publish — this repo contains:
- Terraform code using only placeholder values and variables
- Example `.tfvars` files with fictional, non-functional values
- Documentation referencing fictional infrastructure
- RBAC and identity concepts only — no real users, groups, or service principals

### ❌ This repo does NOT contain:
- Real Azure subscription IDs
- Real tenant IDs or client secrets
- Real IP addresses of production systems
- SSH private keys or certificates
- Storage account keys or SAS tokens
- API keys or tokens of any kind
- Real employee names or contact information (except the portfolio author)
- Any production system credentials

---

## Terraform Safety Guidelines

- `terraform.tfvars` is listed in `.gitignore` — never commit it
- Only `terraform.tfvars.example` files with placeholder values are committed
- No `terraform.tfstate` or `terraform.tfstate.backup` files should ever be committed
- State files are excluded via `.gitignore`
- No `backend` blocks contain real storage account details

---

## .gitignore Requirements

Ensure your local `.gitignore` contains at minimum:

```
*.tfstate
*.tfstate.*
*.tfvars
!*.tfvars.example
.terraform/
.terraform.lock.hcl
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

---

## Branch Protection Recommendations

For teams adapting this reference architecture:

- Require pull request reviews before merging to `main`
- Enable secret scanning on the repository
- Enable Dependabot for provider version alerts
- Do not store Terraform state in this repository — use Azure Storage backend or Terraform Cloud

---

## Compliance Note

This repository is a **reference architecture and portfolio demonstration only**. It does not constitute a compliance certification, legal compliance attestation, or security audit. NERC CIP, TSA Pipeline, and other framework mappings in `COMPLIANCE_MAPPING.md` are conceptual and educational in nature.

---

*Maintained by Loren Lawton, CISSP*
