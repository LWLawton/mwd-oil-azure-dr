# MWD Oil Co. — Azure Hybrid DR & Security Operations Reference Architecture

> **Portfolio Project** | Loren Lawton, CISSP  
> **Disclaimer:** This is a fictional reference architecture built for portfolio and demonstration purposes only. "Maybe We Drill, Maybe We Don't Oil Co." (MWD Oil Co.) is entirely fictional. No real company data, credentials, subscriptions, or infrastructure is represented here. Do not apply this Terraform without reviewing costs and understanding your Azure subscription implications.

---

## 🛢️ Business Scenario

**Maybe We Drill, Maybe We Don't Oil Co. (MWD Oil Co.)** is a mid-size South Texas oil and energy company operating five physical locations across Texas, with active drilling operations in the South Texas Basin. Like many energy companies of its size, MWD Oil Co. has historically relied on expensive co-located physical disaster recovery infrastructure — a second data center that sat mostly idle and consumed budget without delivering confidence.

This project models the security architecture and cloud migration strategy that moves MWD Oil Co. from physical DR to **Azure-based full-site failover**, while demonstrating a mature security operations posture appropriate for an energy sector company subject to NERC CIP, TSA Pipeline Security Directives, and OT/IT convergence challenges.

---

## 🏢 Company Layout

| Site | Location | Role |
|------|----------|------|
| HQ | San Antonio, Texas | Corporate IT, SOC, Identity, Finance, Legal |
| Branch 1 | Corpus Christi, Texas | Pipeline operations, logistics, marine coordination |
| Branch 2 | Midland/Odessa, Texas | Permian Basin field ops, procurement |
| Drill Site A | South Texas Basin | Active drilling, OT/SCADA, IoT sensor arrays |
| Drill Site B | South Texas Basin | Active drilling, OT/SCADA, IoT sensor arrays |

### HQ Critical Systems
- Active Directory / Entra ID hybrid identity
- ERP (SAP S/4HANA placeholder)
- SIEM (Microsoft Sentinel)
- Corporate email and collaboration
- VPN concentrators
- SOC tooling and ticketing

### Branch Critical Systems
- Field operations dashboards
- Logistics and dispatch platforms
- Local file servers (Azure File Sync targets)

### Drill Site Critical Systems
- SCADA / DCS (Distributed Control Systems)
- Historian servers
- IoT sensor aggregation gateways
- Safety Instrumented Systems (SIS) — air-gapped
- OT DMZ jump hosts

---

## ☁️ Azure Design Summary

| Property | Value |
|----------|-------|
| Primary Region | South Central US (San Antonio proximity) |
| DR Region | West US 3 |
| Architecture | Hub-and-Spoke |
| Identity | Entra ID (conceptual, no real users deployed) |
| State | Local (see backend guide for remote state) |
| DR Default | Powered down (count = 0, enable when needed) |

### Hub-and-Spoke Layout

```
Primary Hub VNet (10.0.0.0/16)
├── HQ Spoke        (10.10.0.0/16)
├── Corpus Christi  (10.20.0.0/16)
├── Midland/Odessa  (10.30.0.0/16)
├── Drill Site A    (10.40.0.0/16)
└── Drill Site B    (10.50.0.0/16)

DR Hub VNet (10.100.0.0/16)
└── DR Spokes       (10.110.0.0/16+)
```

---

## 🔐 Security Operations Relevance

This project demonstrates:

- **Cloud security architecture** — hub-and-spoke, NSG design, segmentation
- **Identity hygiene** — RBAC group design, PIM/PAM conceptual integration
- **Ransomware resilience** — immutable backup vaults, segmented recovery paths
- **OT/IoT awareness** — dedicated OT subnet module, IT/OT DMZ design
- **Incident response discipline** — runbooks, DR declaration criteria, failover/failback procedures
- **Compliance mapping** — NERC CIP, TSA Pipeline, IEC 62443, NIST 800-82
- **Vendor coordination** — escalation runbooks, ticket follow-up procedures
- **Documentation maturity** — CISO-facing architecture docs, compliance matrices

---

## 🧪 How to Validate Without Deploying

```bash
# Format check
terraform fmt -recursive

# Initialize without backend (no Azure connection needed)
cd environments/primary
terraform init -backend=false
terraform validate

# Plan (requires Azure subscription configured)
terraform plan

# Only run apply if you understand the cost implications
# See COST_CONTROL.md before proceeding
```

---

## ⚠️ Cost Warnings

- **Do not run `terraform apply` without reading `COST_CONTROL.md`**
- DR resources are set to `count = 0` by default — they will not deploy
- No Azure Firewall, no ExpressRoute, no expensive SKUs by default
- Default VM size is `Standard_B2s` — change via variable
- Estimated lab cost if all primary resources deployed: **~$150–250/month**
- Run `terraform destroy` immediately after testing

See [COST_CONTROL.md](./COST_CONTROL.md) for full guidance.

---

## 📁 Repository Structure

```
mwd-oil-azure-dr/
├── README.md                    # This file
├── SECURITY.md                  # Security policy for this repo
├── COST_CONTROL.md              # Cost warnings and guidance
├── DESTROY_GUIDE.md             # How to safely destroy resources
├── DR_RUNBOOK.md                # Disaster recovery operations runbook
├── FAILOVER_FAILBACK.md         # Failover and failback procedures
├── COMPLIANCE_MAPPING.md        # NERC CIP, TSA, IEC 62443 mapping
├── ARCHITECTURE.md              # Full architecture documentation
├── diagrams/                    # Architecture diagrams (draw.io)
├── environments/
│   ├── primary/                 # Primary region Terraform
│   └── dr/                      # DR region Terraform (count=0 default)
├── modules/
│   ├── network-hub/             # Hub VNet, subnets, peering
│   ├── network-spoke/           # Spoke VNet, NSGs, route tables
│   ├── linux-vm/                # Linux VM module (Ubuntu 22.04)
│   ├── monitoring/              # Log Analytics workspace
│   ├── recovery-vault/          # Recovery Services Vault + ASR
│   ├── storage/                 # Storage accounts with replication
│   ├── sentinel/                # Microsoft Sentinel onboarding
│   ├── defender/                # Defender for Cloud configuration
│   ├── rbac-groups/             # RBAC group documentation stubs
│   └── ot-network/              # OT/IoT subnet and NSG module
├── policies/                    # Azure Policy definitions
├── runbooks/                    # SOC operational runbooks
└── .github/workflows/           # CI validation pipeline
```

---

## 🗺️ Diagram Placeholders

Architecture diagrams are located in `/diagrams/`. See [diagrams/README.md](./diagrams/README.md) for the list of diagrams to be created in draw.io.

---

## 👤 About This Project

**Author:** Loren Lawton, CISSP  
**Purpose:** Security Operations / Cloud Security portfolio demonstration  
**Audience:** CISOs, Security Directors, Hiring Managers evaluating cloud security architecture, incident response maturity, and Terraform engineering capability

This repo is designed to show that a security operations professional can operate across:
- Cloud architecture and IaC
- Incident response and runbook discipline
- Identity and access hygiene
- OT/IoT security awareness
- Compliance framework alignment
- Documentation that a CISO would actually read

---

*MWD Oil Co. — "We might drill. We might not. But we will always secure the perimeter."*
