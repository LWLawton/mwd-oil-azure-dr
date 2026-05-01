# Vendor Ticket Follow-Up Procedure
## Maybe We Drill, Maybe We Don't Oil Co.
## Security Operations Center — Standard Operating Procedure

---

**Document:** SOC-RB-004  
**Version:** 1.0  
**Classification:** INTERNAL — SOC USE  
**Owner:** Security Operations Lead  
**Review Cycle:** Semi-Annual

---

## Purpose

This runbook governs how the MWD Oil Co. SOC manages, tracks, and escalates open security tickets with external vendors — including Microsoft Azure Support, OT/ICS equipment vendors, cybersecurity service providers, and managed security service providers (MSSPs).

Vendor tickets that go untracked are one of the most common causes of extended incident duration. This runbook exists to prevent that.

---

## Vendor Categories

| Category | Examples | Primary Contact Method |
|----------|----------|----------------------|
| Azure / Microsoft | Azure Support, Microsoft TAM | Azure Portal Support + TAM email |
| OT Vendor — Historian | OSIsoft/AVEVA PI, Honeywell | Vendor support portal + phone |
| OT Vendor — SCADA/DCS | Emerson, Yokogawa, ABB | Vendor support portal + phone |
| OT Vendor — Safety Systems | Triconex, Emerson | EMERGENCY: phone only |
| Cybersecurity MSSP | [Placeholder] | Slack / SOC bridge + email |
| ISP / Network | AT&T, Zayo (ExpressRoute) | NOC phone line |
| Cyber Insurance | [Placeholder] | Policy hotline |

---

## Step 1 — Opening a Vendor Ticket

When opening a ticket with an external vendor:

- [ ] Open the ticket with **correct severity** — do not undersell a P1 as a P2 to avoid scrutiny
- [ ] Capture the ticket/case number immediately and enter it in the MWD internal incident ticket
- [ ] Document:
  - Vendor name and support tier (Standard, Premier, TAM-supported)
  - Case number
  - Assigned vendor engineer name (if available)
  - Expected response SLA per your support contract
  - Time opened
  - Summary of the issue and business impact
- [ ] Set a calendar reminder for your first follow-up checkpoint (see SLA table below)

**For Azure Support — Required Information:**
- Azure Subscription ID (do not paste in public channels — use secure ticket)
- Affected region and resource IDs
- Correlation ID from Azure Health or error message
- Start time and description of symptoms
- Impact statement: "X production workloads are unavailable affecting Y users"

---

## Step 2 — Follow-Up Cadence

Do not assume vendors are working your ticket without confirmation. Track every open vendor ticket actively.

| Vendor Severity | Initial Response SLA | MWD Follow-Up Cadence |
|----------------|---------------------|----------------------|
| Severity A (Critical) | 15 minutes | Every 30 minutes until resolved |
| Severity B (High) | 2 hours | Every 2 hours |
| Severity C (Medium) | 8 hours (business hours) | Daily |
| Severity D (Low) | 3 business days | Every 2 business days |

**Follow-up checklist per checkpoint:**
- [ ] Contact vendor by phone if response has not been received within 50% of SLA
- [ ] Record update in internal ticket: what vendor said, next action, next checkpoint time
- [ ] Escalate to MWD SOC Lead if vendor misses SLA without communication
- [ ] If Azure TAM is available: loop them in when vendor engineer is unresponsive

---

## Step 3 — Escalation Path

### Within MWD Oil Co.

| Situation | Escalation |
|-----------|-----------|
| Vendor misses first SLA checkpoint | Notify SOC Lead |
| Vendor misses second SLA checkpoint | SOC Lead notifies CISO |
| Vendor provides no ETR (Estimated Time to Resolution) after 4 hours | CISO engages executive vendor contact |
| Production outage extending beyond 2 hours with no progress | Parallel DR evaluation begins (see DR_RUNBOOK.md) |

### Within the Vendor (Microsoft Azure Example)

1. Request escalation to **Duty Manager** from the assigned support engineer
2. If TAM is available: contact TAM directly and request escalation
3. For Azure outages affecting multiple customers: check Azure Status Page — if platform issue, escalation path is through TAM only
4. For billing or contract disputes: escalate to Microsoft Account Executive, not support

---

## Step 4 — OT Vendor Special Handling

OT vendors (historian, SCADA, DCS, safety systems) require special protocol:

- [ ] **Never allow OT vendor remote access without SOC visibility**
- [ ] All vendor remote sessions to OT assets must be:
  - Scheduled and pre-approved by OT team and SOC
  - Conducted via the OT DMZ jump host — not direct VPN to OT subnet
  - Monitored by a MWD OT admin during the session
  - Recorded if session recording is available
  - Terminated immediately after the session is complete
- [ ] If vendor requests credentials for OT assets: issue temporary, time-limited credentials — not permanent accounts
- [ ] For safety system (SIS) vendor access: require in-person vendor visit — no remote access to SIS assets

---

## Step 5 — Ticket Documentation Requirements

Every vendor ticket must have the following recorded in the internal MWD ticket before closure:

- [ ] Vendor case number and vendor name
- [ ] Timeline: opened → first response → resolution
- [ ] Root cause as stated by vendor
- [ ] Actions taken by vendor and by MWD
- [ ] Whether the vendor met their SLA (yes/no)
- [ ] Outstanding recommendations or follow-up items from vendor
- [ ] Whether a vendor post-incident report was promised (and due date)

---

## Step 6 — Closure and Lessons Learned

When a vendor ticket is resolved:

- [ ] Confirm the resolution with your technical team — don't just take vendor's word
- [ ] If vendor identified a root cause: verify it is addressed, not just the symptom
- [ ] If vendor made changes to MWD systems: verify and document what was changed
- [ ] If vendor missed SLA: document for contract review
- [ ] Update internal runbooks if the incident revealed a process gap
- [ ] Request a vendor post-incident report if the case was a P1 or involved OT

---

## Vendor SLA Tracking Metrics

The SOC tracks the following monthly:

| Metric | Target |
|--------|--------|
| Vendor tickets with timely follow-up | 100% |
| Vendor SLA compliance rate | Tracked per vendor |
| Open vendor tickets older than 7 days | 0 (unacceptable) |
| OT vendor sessions without SOC presence | 0 |

---

*MWD Oil Co. Security Operations — "A vendor ticket is not a closed ticket. Follow up until it is."*
