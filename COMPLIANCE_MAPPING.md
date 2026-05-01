# Compliance Framework Mapping
## MWD Oil Co. — Azure Hybrid DR Reference Architecture
### Document Classification: INTERNAL — COMPLIANCE / SECURITY

> **Portfolio Project** | Loren Lawton, CISSP  
> ⚠️ **This document is a conceptual mapping for educational and portfolio purposes only. It does not constitute a compliance certification, legal compliance attestation, or formal audit finding. Organizations must conduct their own compliance assessments with qualified professionals.**

---

## Overview

MWD Oil Co. operates in the oil and energy sector and is subject to or should be aware of multiple regulatory and standards frameworks governing both IT and operational technology (OT) environments. This document maps architecture and operational controls in this reference project to relevant framework requirements.

---

## NERC CIP — Critical Infrastructure Protection

The North American Electric Reliability Corporation (NERC) Critical Infrastructure Protection standards apply to bulk electric system (BES) assets. While MWD Oil Co. is an oil and gas company rather than a utility, the NERC CIP framework is widely adopted as a reference standard in energy sector security.

### CIP-002: BES Cyber System Categorization

| Control | How This Architecture Addresses It |
|---------|-----------------------------------|
| Identify and categorize BES Cyber Systems | OT subnet module (`modules/ot-network/`) creates dedicated subnets for SCADA, DCS, and IoT assets. NSG tags support asset categorization. |
| Maintain asset inventory | Log Analytics and Defender for Cloud provide continuous asset discovery and inventory. |
| Document high/medium impact systems | ARCHITECTURE.md documents system classifications by site. |

### CIP-003: Security Management Controls

| Control | How This Architecture Addresses It |
|---------|-----------------------------------|
| Cybersecurity policy | This repository and its documentation demonstrate documented security policy and architecture decisions. |
| Leadership accountability | RBAC group design (`modules/rbac-groups/`) establishes ownership and access accountability. |
| Delegate authority | PIM-based RBAC activation provides delegated, time-limited authority. |

### CIP-005: Electronic Security Perimeters

| Control | How This Architecture Addresses It |
|---------|-----------------------------------|
| Define Electronic Security Perimeters (ESP) | OT subnets represent the ESP boundary. NSG rules enforce inbound/outbound restrictions at the subnet level. |
| Control inbound/outbound access | NSGs on OT DMZ subnets restrict access to approved source/destination pairs only. |
| Protect interactive remote access | Management subnet and bastion placeholder provide controlled remote access path. No direct internet SSH. |

### CIP-007: System Security Management

| Control | How This Architecture Addresses It |
|---------|-----------------------------------|
| Ports and services | NSG rules restrict to required ports only. SSH not open to internet (admin CIDR variable). |
| Security patch management | Ubuntu 22.04 LTS used — patch management process should be documented per site. |
| Malicious code prevention | Defender for Cloud Servers plan provides endpoint protection visibility. |
| Security event monitoring | Log Analytics + Sentinel provides SIEM capability with alert rules. |
| System access controls | RBAC groups enforce least privilege. PIM requires justification for elevation. |

### CIP-013: Supply Chain Risk Management

| Control | How This Architecture Addresses It |
|---------|-----------------------------------|
| Vendor risk management | `runbooks/vendor-ticket-followup.md` provides vendor escalation and tracking procedures. |
| Software integrity | Azure Marketplace images used — Microsoft-verified sources only. |
| Software update authenticity | Terraform provider version pinning ensures known-good provider versions. |

### CIP-015: Internal Network Security Monitoring

| Control | How This Architecture Addresses It |
|---------|-----------------------------------|
| Network security monitoring | Log Analytics collects network flow logs and NSG diagnostics. |
| Collect and retain network data | Log Analytics workspace retention configured per compliance requirements. |
| Protect monitoring data | Log Analytics workspace access controlled by RBAC. |

---

## TSA Pipeline Security Directive (Pipeline-2021-02 Series)

The Transportation Security Administration (TSA) Pipeline Security Directives apply to critical pipeline operators. MWD Oil Co.'s pipeline operations in South Texas would fall under these requirements.

| Directive Concept | Architecture Response |
|------------------|----------------------|
| Designate a Cybersecurity Coordinator | CISO role referenced in DR_RUNBOOK.md and FAILOVER_FAILBACK.md. |
| Report cybersecurity incidents to CISA | Communications checklist in DR_RUNBOOK.md includes CISA notification step. |
| Review current practices against TSA recommended measures | This architecture review serves as a reference for gap analysis. |
| Develop and implement a Cybersecurity Incident Response Plan | DR_RUNBOOK.md and runbooks directory provide the foundation for a CIRP. |
| Establish network segmentation | Hub-and-spoke with IT/OT segmentation at drill sites (see ARCHITECTURE.md). |
| Access control measures | RBAC groups, PIM, no shared credentials, admin CIDR restrictions. |
| Continuous monitoring | Log Analytics + Sentinel continuous monitoring with alerting. |
| Patch management | Ubuntu LTS + documented patch process. Defender for Cloud tracks patch compliance. |

---

## DOE Cybersecurity Capability Maturity Model (C2M2)

The Department of Energy C2M2 provides a maturity framework for energy sector cybersecurity programs.

| Domain | Maturity Indicator in This Architecture |
|--------|----------------------------------------|
| Asset, Change, and Configuration Management | Terraform IaC provides configuration management. Defender for Cloud tracks asset inventory. |
| Identity and Access Management | Entra ID + RBAC + PIM design demonstrates IAM maturity. |
| Threat and Vulnerability Management | Defender for Cloud provides vulnerability assessment. Sentinel provides threat detection. |
| Situational Awareness | Log Analytics + Sentinel dashboards provide operational awareness. |
| Information Sharing and Communications | DR_RUNBOOK.md communications procedures. |
| Event and Incident Response, Continuity | Full DR runbook, failover/failback procedures, lessons learned process. |
| Supply Chain and External Dependencies Management | Vendor runbook, Terraform provider version pinning. |
| Workforce Management | RBAC groups, PIM role activation with justification. |
| Cybersecurity Architecture | Hub-and-spoke, IT/OT segmentation, NSG design. |

---

## IEC 62443 — Industrial Automation and Control Systems Security

IEC 62443 is the primary OT security standard applicable to industrial control systems including oil and gas operations.

| Standard Section | Architecture Response |
|-----------------|----------------------|
| 62443-2-1: Security Management System | DR_RUNBOOK.md and runbooks/ provide documented security management procedures. |
| 62443-3-2: Security Risk Assessment | ARCHITECTURE.md documents risk-based segmentation decisions. |
| 62443-3-3: System Security Requirements (Zones and Conduits) | OT subnet zones (IT, OT DMZ, OT, IoT) with NSG conduit controls. |
| 62443-4-2: Component Security Requirements | Ubuntu hardening guide referenced; Defender for Cloud provides component visibility. |

### Security Level Zones (IEC 62443-3-3)

| Zone | Subnet | Security Level Target |
|------|--------|----------------------|
| Enterprise (SL1) | HQ/Branch subnets | SL1 — Low |
| OT DMZ (SL2) | ot-dmz-subnet | SL2 — Medium |
| OT Control (SL3) | ot-subnet | SL3 — High |
| Safety Systems | Air-gapped (not in scope) | SL4 — Very High |

---

## ISO/IEC 27019 — Information Security for Energy Utilities

ISO/IEC 27019 extends ISO 27001 for energy utility control systems.

| Control Area | Architecture Response |
|-------------|----------------------|
| Security policy for process control | Documented in ARCHITECTURE.md and this compliance mapping. |
| Physical and environmental security | Addressed by Azure data center physical security (Microsoft responsibility). |
| Access control for process control | OT subnet NSG rules, no internet-direct access to OT. |
| Network separation | Hub-and-spoke with OT DMZ enforces network separation. |
| Logging and monitoring | Log Analytics captures OT DMZ events. |
| Incident management | DR_RUNBOOK.md + individual SOC runbooks. |
| Business continuity | Full DR architecture with RTO/RPO targets. |

---

## NIST SP 800-82: Guide to ICS Security

NIST SP 800-82 provides guidance for industrial control system security.

| NIST Control Family | Architecture Response |
|--------------------|----------------------|
| AC — Access Control | RBAC, PIM, no shared credentials, admin CIDR NSG rules. |
| AU — Audit and Accountability | Log Analytics retention, Sentinel incident tracking. |
| CA — Assessment, Authorization, Monitoring | Defender for Cloud continuous assessment. |
| CM — Configuration Management | Terraform IaC, version-controlled configuration. |
| IA — Identification and Authentication | Entra ID, MFA, PIM elevation. |
| IR — Incident Response | DR_RUNBOOK.md, all runbooks in runbooks/ directory. |
| MA — Maintenance | Ubuntu LTS, patch management process referenced. |
| MP — Media Protection | Not addressed in this reference architecture. |
| PE — Physical and Environmental | Azure data center (Microsoft responsibility). |
| PL — Planning | ARCHITECTURE.md, DR documentation. |
| RA — Risk Assessment | Architecture decisions documented with rationale. |
| SC — System and Communications Protection | NSGs, subnet segmentation, hub-and-spoke isolation. |
| SI — System and Information Integrity | Defender for Cloud, Sentinel analytics rules. |

---

## Ransomware Resilience Controls

Given the elevated ransomware risk to energy sector companies, this architecture specifically addresses ransomware resilience:

| Control | Implementation |
|---------|--------------|
| Immutable backups | Recovery Services Vault with soft-delete + immutability option documented |
| Offline/isolated recovery path | DR region is separate from primary — isolated recovery environment |
| Network segmentation | Hub-and-spoke prevents lateral movement across sites |
| OT isolation | OT subnets have no internet access — limits ransomware propagation path |
| Rapid detection | Sentinel analytics rules for encryption indicators, mass file changes |
| Tested recovery | DR exercises validate recovery capability |
| Backup monitoring | Recovery Vault alerts on backup job failures |
| Identity hygiene | PIM limits persistent privileged access that ransomware operators exploit |
| Dedicated containment runbook | See `runbooks/ransomware-containment.md` |

---

*All framework mappings are conceptual and educational. Compliance determination requires qualified assessment by certified professionals familiar with your specific environment and regulatory obligations.*
