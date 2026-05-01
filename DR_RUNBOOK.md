# Disaster Recovery Operations Runbook
## MWD Oil Co. — Azure Hybrid DR
### Document Classification: INTERNAL — SOC USE ONLY

> **Version:** 1.0 | **Owner:** Security Operations / Cloud Infrastructure  
> **Review Cycle:** Quarterly | **Last Updated:** See Git history  
> **Portfolio Project** | Loren Lawton, CISSP

---

## Purpose

This runbook governs the declaration, execution, and closure of a disaster recovery event for MWD Oil Co.'s Azure-hosted infrastructure. It is designed for use by the Security Operations team, Cloud Infrastructure team, and executive stakeholders during an active incident.

---

## Declaration Criteria

A DR event may be declared when **one or more** of the following conditions are met:

| Condition | Threshold | Declaring Authority |
|-----------|-----------|-------------------|
| Primary Azure region unavailable | >30 minutes confirmed | CISO or VP Infrastructure |
| HQ site physically inaccessible | Confirmed by physical security | CISO or COO |
| Ransomware confirmed in primary environment | SOC triage confirms encryption | CISO |
| Primary VPN/connectivity loss to all sites | >60 minutes, no ETA | VP Infrastructure |
| Critical VM cluster unavailable | Affects ERP, identity, or SOC tooling | On-call Cloud Architect |

> **Do not declare DR based on a single monitoring alert alone.** Require human confirmation from two independent sources before declaring.

---

## Step 1 — Initial Alert Enrichment

When a potential DR-triggering event is detected:

- [ ] Identify the alert source (Sentinel incident, Azure Health alert, user report, site call)
- [ ] Check Azure Service Health dashboard for regional outage notices
- [ ] Check Sentinel for correlated incidents in the past 2 hours
- [ ] Query Log Analytics for VM heartbeat loss:
  ```kusto
  Heartbeat
  | where TimeGenerated > ago(30m)
  | summarize LastHeartbeat = max(TimeGenerated) by Computer
  | where LastHeartbeat < ago(15m)
  ```
- [ ] Verify primary hub VNet reachability from at least two sites
- [ ] Check storage account replication lag in Azure Monitor
- [ ] Document findings in the security ticket with timestamp

---

## Step 2 — Security Ticket Workflow

All DR events require a formal security ticket opened within **15 minutes** of initial detection.

**Ticket Fields Required:**
- Incident classification: DR / Infrastructure / Security
- Severity: P1 (DR declaration) or P2 (potential DR)
- Affected systems: List all confirmed unavailable resources
- Detection source and time
- Initial impact assessment (IT only, OT involved, safety systems affected)
- Lead responder and backup responder assigned

**Ticket Escalation Path:**
1. SOC Analyst → SOC Lead (immediate)
2. SOC Lead → CISO (within 15 minutes of P1)
3. CISO → COO and CTO (within 30 minutes of P1)
4. COO → Executive team and legal (as warranted)

---

## Step 3 — IAM / PIM / PAM Verification

Before executing failover, verify privileged access is available in DR:

- [ ] Confirm `mwd-cloud-admins` break-glass accounts are accessible
- [ ] Activate PIM roles for `mwd-cloud-admins` and `mwd-security-ops` groups
- [ ] Verify MFA is functional for all responders (if primary IdP is impacted, confirm Entra ID is globally available)
- [ ] Confirm PAM vault (if in use) is accessible or that break-glass credentials are available offline
- [ ] Document who activated elevated access and at what time
- [ ] Notify CISO of all privileged access activations

> **Note:** Entra ID is a global service and does not fail over with Azure regions. Identity availability is independent of compute failover.

---

## Step 4 — Vendor Escalation

If the incident involves an Azure platform failure or third-party vendor:

- [ ] Open Azure Support ticket at **Severity A** (production down)
  - Portal: https://portal.azure.com → Help + Support
  - Required: Subscription ID, affected region, correlation ID from Azure Health
- [ ] Contact Microsoft TAM (Technical Account Manager) if applicable
- [ ] If OT/SCADA vendor involvement needed, contact vendor per OT Vendor Contact List (stored offline in SOC binder)
- [ ] Log all vendor ticket numbers in the security incident ticket
- [ ] Set 30-minute follow-up checkpoints for vendor updates
- [ ] See runbook: [runbooks/vendor-ticket-followup.md](./runbooks/vendor-ticket-followup.md)

---

## Step 5 — Failover Decision Tree

```
Is the primary Azure region confirmed unavailable?
├── YES → Is outage expected to exceed 4 hours (RTO threshold)?
│         ├── YES → Proceed to FULL FAILOVER (Step 6)
│         └── NO  → Activate STANDBY MONITORING, reassess in 60 min
└── NO  → Is the incident limited to specific workloads?
          ├── YES → Perform TARGETED RECOVERY (restore from backup/snapshot)
          └── NO  → Continue enrichment, do not declare DR yet
```

---

## Step 6 — Failover Execution

See [FAILOVER_FAILBACK.md](./FAILOVER_FAILBACK.md) for detailed failover procedures.

Summary:
- [ ] Enable DR resources: set `count = 1` in `environments/dr/main.tf`
- [ ] Run `terraform apply` in DR environment
- [ ] Initiate ASR failover for critical VMs
- [ ] Execute DNS cutover
- [ ] Validate identity, logging, and OT telemetry in DR
- [ ] Notify all site contacts of DR activation

---

## Step 7 — Communications Checklist

During an active DR event, communications must be managed to avoid confusion and protect sensitive information.

**Internal Communications:**
- [ ] Activate incident bridge (Teams/Zoom bridge details in offline SOC binder)
- [ ] Status updates to CISO every 30 minutes until stable
- [ ] Site leads notified of DR status (HQ, Corpus Christi, Midland, Drill Sites A/B)
- [ ] IT helpdesk notified to redirect user issues to SOC during event

**External Communications:**
- [ ] Legal and compliance team notified if data impact is suspected
- [ ] Cyber insurance carrier notified per policy requirements (typically within 24–72 hours)
- [ ] CISA notification if critical infrastructure impact (per CIRCIA if applicable)
- [ ] No public statements without CISO and legal approval

---

## Step 8 — Restore Validation

Before declaring recovery complete:

- [ ] All critical VMs responding to heartbeat in Log Analytics
- [ ] ERP system accessible and functional (HQ team confirms)
- [ ] VPN tunnels to all sites re-established
- [ ] OT telemetry flowing from Drill Sites A and B
- [ ] Sentinel receiving log data from all sources
- [ ] Backup jobs running on restored VMs
- [ ] No open Sentinel incidents related to DR event unresolved
- [ ] Storage account replication healthy

---

## Step 9 — Lessons Learned

Within **72 hours** of DR event closure:

- [ ] Schedule post-incident review with all responders
- [ ] Document timeline: detection → declaration → failover → recovery
- [ ] Identify gaps in runbook procedures
- [ ] Identify monitoring blind spots that delayed detection
- [ ] Review RTO/RPO actuals vs targets
- [ ] Update this runbook with findings
- [ ] Submit runbook update to CISO for approval

**Lessons Learned Template:**

| Item | Finding | Recommendation | Owner | Due Date |
|------|---------|---------------|-------|----------|
| | | | | |

---

## Reference Contacts (Placeholder)

> Replace with real contact information. Do not store in this public repository.

| Role | Name | Contact Method |
|------|------|---------------|
| CISO | [PLACEHOLDER] | [SECURE CHANNEL] |
| VP Infrastructure | [PLACEHOLDER] | [SECURE CHANNEL] |
| Azure TAM | [PLACEHOLDER] | [PLACEHOLDER] |
| OT Vendor Lead | [PLACEHOLDER] | [PLACEHOLDER] |
| Cyber Insurance | [PLACEHOLDER] | Policy # [PLACEHOLDER] |

---

*MWD Oil Co. Security Operations — "Secure the perimeter. Protect the basin."*
