# Ransomware Containment Procedure
## Maybe We Drill, Maybe We Don't Oil Co.
## Security Operations Center — EMERGENCY RESPONSE PROCEDURE

---

**Document:** SOC-RB-005  
**Version:** 1.3  
**Classification:** INTERNAL — SOC / CISO / EXECUTIVE — RESTRICTED  
**Owner:** CISO / Security Operations Lead  
**Review Cycle:** Semi-Annual + Post-Incident

---

> ⚠️ **THIS IS AN EMERGENCY RESPONSE DOCUMENT**  
> If ransomware is actively encrypting files or systems, **DO NOT DELAY** reading this document. Begin containment immediately at Step 2 while another responder reads ahead.

---

## Ransomware Indicators — Know Them On Sight

| Indicator | What It Looks Like |
|-----------|-------------------|
| File extension changes | Files renamed to `.locked`, `.encrypted`, `.mwd`, random extensions |
| Ransom note dropped | `README.txt`, `DECRYPT.html`, `HOW_TO_RECOVER.txt` on desktops/shares |
| Mass file encryption | Disk I/O spike, CPU spike, File Share activity spike in Azure Monitor |
| Shadow copy deletion | `vssadmin delete shadows` or `wmic shadowcopy delete` in process logs |
| Lateral movement | Sudden new admin sessions across multiple systems within minutes |
| Sentinel alert | "Mass file deletion" rule or "Unusual process execution" alert |
| User reports | Multiple users reporting files won't open, unusual file extensions |

---

## Step 1 — Confirm and Declare

- [ ] Confirm ransomware activity through at least two independent indicators
- [ ] Do NOT assume it is ransomware based solely on a single user report — verify
- [ ] If confirmed: **Declare a P1 Security Incident immediately**
- [ ] Notify CISO by phone — do not rely on email (email may be compromised or impacted)
- [ ] Open the incident ticket: "RANSOMWARE SUSPECTED — [Date/Time]"
- [ ] Activate the incident bridge

> **If OT systems appear affected:** Notify the OT site supervisor by phone immediately. Do not take any action on OT systems without OT team coordination. Ransomware in OT environments can affect physical operations.

---

## Step 2 — Immediate Containment (First 15 Minutes)

Speed of containment determines blast radius. Act now, investigate after.

### Network Isolation

- [ ] Identify the affected VMs or subnets
- [ ] Apply emergency deny-all NSG to affected VMs via Azure Portal or CLI:
  ```bash
  # Emergency NSG lockdown on affected VM NIC
  az network nic update \
    --name AFFECTED_NIC_NAME \
    --resource-group RESOURCE_GROUP \
    --network-security-group ""   # Detach current NSG first if needed

  # Create emergency deny-all NSG
  az network nsg create \
    --name nsg-emergency-isolate \
    --resource-group RESOURCE_GROUP \
    --location southcentralus

  # Add deny-all rules
  az network nsg rule create \
    --nsg-name nsg-emergency-isolate \
    --resource-group RESOURCE_GROUP \
    --name DenyAllInbound \
    --priority 100 \
    --direction Inbound \
    --access Deny \
    --protocol "*" \
    --source-address-prefixes "*" \
    --destination-port-ranges "*"
  ```

- [ ] If Defender for Endpoint is deployed: use "Isolate device" from the Defender portal
- [ ] Do NOT power off VMs unless explicitly directed — forensic evidence lives in memory
- [ ] Isolate OT DMZ from IT network at NSG level if OT DMZ is affected or potentially exposed

### Credential Containment

- [ ] Revoke all active sessions for accounts known to be on affected systems:
  - Entra ID → Users → [User] → Revoke sign-in sessions
- [ ] Reset passwords for any accounts that may have been harvested (admin, service accounts)
- [ ] Rotate any service principal secrets that were used on affected systems
- [ ] Disable any accounts that show active movement across multiple systems simultaneously
- [ ] Activate break-glass accounts if primary admin accounts are compromised

---

## Step 3 — Scope Assessment (First 30 Minutes)

While containment runs, begin scoping:

```kusto
// Identify systems with ransomware indicators in the past 2 hours
Syslog
| where TimeGenerated > ago(2h)
| where SyslogMessage has_any ("vssadmin", "shadowcopy", "wbadmin", "bcdedit", "cipher /w")
| project TimeGenerated, HostName, SyslogMessage
| order by TimeGenerated desc
```

```kusto
// Unusual file activity volume by host
Syslog
| where TimeGenerated > ago(1h)
| where Facility == "kern" and SyslogMessage has_any ("rename", "unlink", "truncate")
| summarize EventCount = count() by HostName, bin(TimeGenerated, 5m)
| where EventCount > 500
| order by EventCount desc
```

- [ ] Identify Patient Zero — which system was first affected?
- [ ] Map the spread — which systems are confirmed encrypted vs potentially exposed?
- [ ] Identify the ransomware strain if possible (extension, note, known signatures)
- [ ] Determine whether the attacker is still active or whether encryption is complete
- [ ] Check for data exfiltration indicators (large outbound transfers before encryption)

---

## Step 4 — OT / Drill Site Assessment

- [ ] Contact Drill Site A supervisor: confirm SCADA, DCS, historian operational status
- [ ] Contact Drill Site B supervisor: same
- [ ] Confirm OT DMZ systems are isolated from IT network
- [ ] Confirm Safety Instrumented Systems are operating normally (they are air-gapped — should be unaffected)
- [ ] If historian is compromised: assess whether SCADA can operate without historian temporarily
- [ ] Brief OT leads: do not reconnect any OT system to IT network until SOC gives all-clear

---

## Step 5 — Preserve Evidence (Do Not Destroy)

- [ ] **Do NOT run AV scans that may delete malware samples** before forensic preservation
- [ ] Capture VM snapshots of affected systems in Azure before any remediation
- [ ] Preserve Azure Activity Logs, NSG Flow Logs, and Syslog for affected systems
- [ ] Preserve ransom note files — they may identify the threat actor group
- [ ] If law enforcement or cyber insurance is involved: establish evidence chain of custody
- [ ] Document everything with timestamps in the incident ticket

---

## Step 6 — Notification and Legal

- [ ] Notify CISO (if not already notified)
- [ ] CISO notifies COO and executive team
- [ ] Engage cyber insurance carrier per policy requirements
  - Carrier phone: [PLACEHOLDER — stored offline in SOC binder]
  - Policy number: [PLACEHOLDER]
- [ ] Engage external incident response retainer if available
- [ ] Legal team notified — assess whether data exfiltration triggers breach notification obligations
- [ ] CISA notification if critical infrastructure (pipeline, drilling) is impacted
- [ ] Do NOT communicate with ransomware operators without legal and executive approval

---

## Step 7 — Recovery Planning

Before restoring any system, verify:

- [ ] The attack vector is identified and closed (patch, credential rotation, MFA enforced)
- [ ] Attacker persistence mechanisms are removed from all systems (check scheduled tasks, cron, startup scripts, new user accounts)
- [ ] Backups are confirmed clean — verify backup restore points predate the compromise
- [ ] Recovery Services Vault integrity confirmed — no tampering with backup data

**Restoration Order (Priority):**
1. Identity infrastructure (domain controllers / Entra ID — likely unaffected)
2. Log Analytics / Sentinel (restore security visibility first)
3. Critical business systems (ERP, financial)
4. File servers and collaboration
5. OT historian (only after OT team confirms readiness)

---

## Step 8 — Post-Incident

Within 5 business days:

- [ ] Confirm all attacker persistence removed across all systems
- [ ] Complete full privileged access review (see `privileged-access-review.md`)
- [ ] Conduct Lessons Learned meeting
- [ ] Update this runbook with findings
- [ ] Submit insurance claim documentation
- [ ] Review backup and DR posture — did the architecture perform as expected?
- [ ] Consider Immutable Vault setting on Recovery Services Vault to prevent future tampering

---

## Decision: Pay or Not Pay Ransom

This decision belongs exclusively to the CISO, COO, CEO, and Legal — not to the SOC.

The SOC's job is to:
1. Maximize recovery capability from clean backups
2. Provide accurate scope and impact data to decision-makers
3. Preserve evidence regardless of the business decision
4. Implement whatever recovery path leadership authorizes

The SOC does not independently contact or engage ransomware operators.

---

*MWD Oil Co. Security Operations — "Contain fast. Recover clean. Never pay alone."*
