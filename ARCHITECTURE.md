# Architecture Reference — MWD Oil Co. Azure Hybrid DR

> **Portfolio Project** | Loren Lawton, CISSP  
> Fictional reference architecture for "Maybe We Drill, Maybe We Don't Oil Co."

---

## Overview

MWD Oil Co. operates a hybrid IT/OT environment across five physical sites in Texas. This architecture models the transition from co-located physical disaster recovery to Azure-based full-site failover, while maintaining strict IT/OT segmentation required for energy sector operations.

---

## Hub-and-Spoke Design

### Why Hub-and-Spoke?

Hub-and-spoke is the preferred Azure network topology for multi-site organizations because:
- Centralized network security and routing policies live in the hub
- Spokes are isolated from each other by default (no spoke-to-spoke traffic without hub transit)
- New sites can be added as spokes without redesigning the core
- ExpressRoute and VPN terminate in the hub, not in individual spokes

### Primary Region — South Central US

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRIMARY HUB (10.0.0.0/16)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ GatewaySubnet│  │ ManagementSN │  │   SharedServices SN  │  │
│  │ 10.0.0.0/27  │  │ 10.0.1.0/24  │  │   10.0.2.0/24        │  │
│  └──────┬───────┘  └──────────────┘  └──────────────────────┘  │
│         │ VPN Gateway (Active/Active)                            │
└─────────┼───────────────────────────────────────────────────────┘
          │ VNet Peering (Hub-to-Spoke)
    ┌─────┴──────────────────────────────────────────────┐
    │                                                     │
┌───▼────────────┐  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐  ┌──────────────┐
│  HQ Spoke      │  │ Corpus Chr.  │  │ Midland Spoke │  │ Drill Site A │  │ Drill Site B │
│  10.10.0.0/16  │  │ 10.20.0.0/16 │  │ 10.30.0.0/16  │  │ 10.40.0.0/16 │  │ 10.50.0.0/16 │
└────────────────┘  └──────────────┘  └───────────────┘  └──────────────┘  └──────────────┘
```

### DR Region — West US 3

DR hub and spokes mirror the primary layout under `10.100.0.0/16` onwards. All DR resources are set to `count = 0` by default and must be explicitly enabled for a failover exercise.

---

## Subnet Design

### HQ Spoke Subnets (10.10.0.0/16)

| Subnet | CIDR | Purpose |
|--------|------|---------|
| app-subnet | 10.10.1.0/24 | Application servers, ERP |
| mgmt-subnet | 10.10.2.0/24 | Management and bastion jump hosts |
| data-subnet | 10.10.3.0/24 | Databases, file servers |
| identity-subnet | 10.10.4.0/24 | Domain controllers (conceptual) |

### Drill Site Spokes (10.40.0.0/16, 10.50.0.0/16)

| Subnet | CIDR | Purpose |
|--------|------|---------|
| it-subnet | 10.40.1.0/24 | Corporate IT at site |
| ot-dmz-subnet | 10.40.2.0/24 | OT/IT DMZ — historian, jump hosts |
| ot-subnet | 10.40.3.0/24 | SCADA, DCS, PLCs (conceptual) |
| iot-subnet | 10.40.4.0/24 | IoT sensor aggregation gateways |

---

## IT vs OT Segmentation

Energy sector environments require strict separation between corporate IT networks and operational technology (OT) networks. A compromise of the OT environment can result in physical equipment damage, environmental incidents, or safety system failures.

### Segmentation Layers

```
INTERNET
    │
    ▼
[Azure VPN Gateway / ExpressRoute]
    │
    ▼
[HUB VNet — Corporate IT]
    │
    ├── HQ, Branch Spokes (standard corporate IT)
    │
    └── Drill Site Spokes
              │
              ├── IT Subnet (corporate access)
              │
              ├── OT DMZ Subnet ◄── Historian, PI Server, Jump Hosts
              │       │
              │       │ (NSG controlled — limited ports, monitored)
              │       ▼
              └── OT Subnet ◄── SCADA/DCS/PLC (no internet, no Azure routing)
                      │
                      └── IoT Subnet ◄── Sensor gateways (unidirectional data flow)
```

### NSG Rules for OT DMZ

- OT DMZ allows inbound from IT subnet on specific historian ports only
- OT DMZ does NOT allow inbound from internet
- OT subnet has no outbound to internet
- IoT sensor data flows one-way: IoT → OT DMZ → Historian → IT (via approved paths only)
- Safety Instrumented Systems (SIS) are **air-gapped** and not represented in this Terraform

### Purdue Model Reference

This architecture conceptually follows the Purdue Enterprise Reference Architecture:
- Level 4/5 (Enterprise/Cloud): Azure Hub, HQ Spoke
- Level 3.5 (OT DMZ): ot-dmz-subnet
- Level 3 (Site Operations): ot-subnet
- Level 2/1/0 (Control/Field): SIS systems (air-gapped, not in scope for Azure)

---

## VPN and ExpressRoute Connectivity

### Primary Connectivity (Conceptual)

| Site | Connection Type | Status in Terraform |
|------|----------------|-------------------|
| HQ San Antonio | ExpressRoute (primary) + VPN (backup) | VPN deployed, ExpressRoute placeholder |
| Corpus Christi | Site-to-Site VPN | Placeholder — local gateway only |
| Midland/Odessa | Site-to-Site VPN | Placeholder — local gateway only |
| Drill Site A | VPN over LTE/satellite | Placeholder |
| Drill Site B | VPN over LTE/satellite | Placeholder |

### DR Connectivity

In a declared disaster, connectivity to the DR region is established via:
1. VPN Gateway in DR Hub activates (count changed from 0 to 1)
2. DNS cutover redirects application traffic to DR endpoints
3. Site VPN tunnels are re-terminated at DR hub gateway

---

## Monitoring and Logging Flow

```
All Azure Resources
       │
       ▼ Diagnostic Settings
Log Analytics Workspace (primary)
       │
       ├── Microsoft Sentinel (SIEM overlay)
       │       │
       │       └── Analytics Rules → Incidents → SOC Triage
       │
       ├── Microsoft Defender for Cloud
       │       │
       │       └── Security Score → Recommendations → Remediation
       │
       └── Workbooks / Dashboards
               │
               └── DR Region Log Analytics (replication target)
```

### OT Telemetry Path

OT/IoT sites forward telemetry via:
1. On-premises historian → Azure IoT Hub (conceptual) → Log Analytics
2. OT DMZ syslog → Azure Monitor Agent → Log Analytics
3. Security events from OT DMZ jump hosts → Sentinel

---

## Failover Strategy

### RTO and RPO Targets

| Metric | Target | Method |
|--------|--------|--------|
| RTO (Recovery Time Objective) | 4 hours | Azure Site Recovery + pre-staged DR infra |
| RPO (Recovery Point Objective) | 15 minutes | ASR replication + GRS storage |

### Failover Architecture Assumptions

- VMs are replicated to DR region via Azure Site Recovery
- Storage accounts use GRS replication (15-minute async lag)
- Log Analytics is independent per region (no cross-region dependency)
- DNS is managed externally — cutover is manual step in runbook
- Identity (Entra ID) is globally available — no failover needed

### Failover Decision Tiers

| Tier | Scenario | Response |
|------|----------|----------|
| Tier 1 | Single VM failure | Azure auto-restart, no DR needed |
| Tier 2 | Availability Zone failure | Zone-redundant resources absorb, monitor |
| Tier 3 | Primary region degraded | Partial failover of critical workloads |
| Tier 4 | Primary region unavailable | Full site failover to DR region |

See [FAILOVER_FAILBACK.md](./FAILOVER_FAILBACK.md) for detailed procedures.

---

## Identity Architecture (Conceptual)

MWD Oil Co. uses Entra ID (formerly Azure AD) as the cloud identity provider with hybrid sync from on-premises Active Directory.

> No real users, groups, or service principals are deployed by this Terraform.

### RBAC Group Design

| Group Name | Role | Scope |
|-----------|------|-------|
| mwd-cloud-admins | Owner (break-glass only) | Subscription |
| mwd-security-ops | Security Reader + Sentinel Contributor | Subscription |
| mwd-network-ops | Network Contributor | Network RGs only |
| mwd-vm-ops | Virtual Machine Contributor | Compute RGs only |
| mwd-readonly | Reader | Subscription |
| mwd-ot-admins | Contributor (OT RGs only) | OT Resource Groups |

PIM (Privileged Identity Management) is recommended for all elevated roles. See `modules/rbac-groups/` for documentation stubs.

---

## Backup and Recovery Architecture

- Recovery Services Vault deployed in primary region
- ASR replication configured conceptually for all critical VMs
- Soft-delete enabled on vault (14-day retention)
- Immutable vault option documented (recommended for ransomware resilience)
- Backup policies: daily VM snapshots, 30-day retention
- Storage account replication: GRS (15-minute RPO for blob data)

---

*Architecture designed to support NERC CIP, TSA Pipeline Security Directive, IEC 62443, and NIST SP 800-82 conceptual compliance. See COMPLIANCE_MAPPING.md for control mapping.*
