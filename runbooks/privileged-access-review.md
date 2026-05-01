# Privileged Access Review Procedure
## Maybe We Drill, Maybe We Don't Oil Co.
## Security Operations Center — Standard Operating Procedure

---

**Document:** SOC-RB-003  
**Version:** 1.0  
**Classification:** INTERNAL — SOC / IAM USE  
**Owner:** Security Operations Lead / Identity & Access Management  
**Review Cycle:** Monthly (standing review) / Ad-hoc (incident-driven)

---

## Purpose

This runbook defines the process for reviewing, validating, and remediating privileged access across MWD Oil Co.'s Azure environment, Entra ID, and on-premises systems. It covers both scheduled reviews and emergency privilege audits triggered during incidents.

---

## When This Runbook Is Triggered

| Trigger | Frequency | Priority |
|---------|-----------|----------|
| Scheduled quarterly access review | Every 90 days | Standard |
| Employee departure or role change | Within 24 hours | High |
| Security incident involving privileged account | Immediately | P1 |
| Unusual privileged activity alert from Sentinel | Immediately | P1/P2 |
| DR declaration | Immediately | P1 |
| Post-penetration test | Within 48 hours | High |

---

## Step 1 — Identify All Privileged Accounts

- [ ] Export current Owner and Contributor role assignments at subscription scope:
  ```bash
  az role assignment list --scope /subscriptions/SUBSCRIPTION_ID \
    --role "Owner" --output table

  az role assignment list --scope /subscriptions/SUBSCRIPTION_ID \
    --role "Contributor" --output table
  ```

- [ ] Export all PIM-eligible role assignments (Entra ID → Identity Governance → Privileged Identity Management)
- [ ] Export all Entra ID Global Administrators and Privileged Role Administrators
- [ ] Export all active (non-PIM) elevated assignments — these should be zero except break-glass
- [ ] Document findings in review spreadsheet or ticket

---

## Step 2 — Validate Each Assignment

For each privileged assignment found:

- [ ] Is the assignment expected and documented?
- [ ] Is the principal a human user, service principal, or managed identity?
- [ ] Does the assignment follow least privilege? (Is Contributor appropriate, or would a custom role suffice?)
- [ ] Is this a permanent assignment? If so, should it be PIM-eligible instead?
- [ ] When was this role last activated? (Check PIM audit logs)
- [ ] Has the user's role or employment status changed?

**Red Flags — Immediate Investigation Required:**
- Owner assignment with no ticket or documented justification
- Assignment created outside of normal business hours
- Service principal with Owner at subscription scope
- Guest user with elevated permissions
- Assignment created on the same day as an alert or incident

---

## Step 3 — PIM Activation Audit

Review PIM activation history for anomalies:

```kusto
// Sentinel / Log Analytics — PIM role activations
AuditLogs
| where OperationName == "Add member to role completed (PIM activation)"
| where TimeGenerated > ago(30d)
| extend ActivatedBy = tostring(InitiatedBy.user.userPrincipalName)
| extend RoleActivated = tostring(TargetResources[0].displayName)
| extend Justification = tostring(AdditionalDetails[?(@.key == "reason")].value)
| project TimeGenerated, ActivatedBy, RoleActivated, Justification
| order by TimeGenerated desc
```

Flag any activation that:
- Lacks a justification comment
- Was performed outside business hours without a documented incident
- Activated a role the user has never used before
- Resulted in an unusually long session duration

---

## Step 4 — Service Principal Review

Service principals are often overlooked and can become persistent privileged backdoors:

- [ ] List all service principals with Azure role assignments:
  ```bash
  az ad sp list --all --query "[].{AppId:appId, DisplayName:displayName}" --output table
  ```
- [ ] For each SP with elevated roles: verify the owning application is still in use
- [ ] Check SP credential expiration dates — expired credentials may indicate abandoned apps
- [ ] Verify no SP has a client secret that has never been rotated
- [ ] Remove SP role assignments for decommissioned applications immediately

---

## Step 5 — Break-Glass Account Verification

MWD Oil Co. maintains break-glass accounts for emergency access if Entra ID PIM or MFA becomes unavailable:

- [ ] Confirm break-glass accounts exist and are known to CISO and at least one other executive
- [ ] Confirm break-glass accounts are NOT in scope for Conditional Access MFA (by design — emergency access only)
- [ ] Confirm break-glass account credentials are stored offline (not in a password manager connected to Azure)
- [ ] Verify no one has logged in with break-glass accounts since last review (alert if login detected)
- [ ] Test break-glass account login at least annually

```kusto
// Detect break-glass account usage
SigninLogs
| where UserPrincipalName in ("breakglass1@mwdoilco.example.com", "breakglass2@mwdoilco.example.com")
| where TimeGenerated > ago(90d)
| project TimeGenerated, UserPrincipalName, IPAddress, Location, ResultType
```

---

## Step 6 — OT Access Review

OT access requires additional scrutiny due to physical impact potential:

- [ ] Review access to OT DMZ jump hosts (who has SSH keys deployed?)
- [ ] Review OT vendor remote access accounts — confirm they are temporary and time-limited
- [ ] Confirm no OT admin accounts are shared (individual accountability required)
- [ ] Verify OT admin accounts are NOT synced to cloud Entra ID (OT identity should be isolated)
- [ ] Check for any IT-side accounts with access to OT DMZ subnets that are unexpected

---

## Step 7 — Remediation

For each finding that requires action:

| Finding | Remediation Action | SLA |
|---------|--------------------|-----|
| Orphaned privileged assignment | Remove immediately | Same day |
| Permanent Owner assignment (non-break-glass) | Convert to PIM-eligible | 48 hours |
| SP with unused elevated role | Remove role assignment | 24 hours |
| User with excessive scope | Scope-down to minimum required | 48 hours |
| Undocumented break-glass usage | Investigate and notify CISO | Immediate |
| OT shared account found | Disable and re-provision individual accounts | 24 hours |

---

## Step 8 — Document and Report

- [ ] Record all findings in the access review ticket
- [ ] Produce a summary table: total assignments reviewed, issues found, remediations completed
- [ ] Submit report to CISO within 5 business days of review completion
- [ ] Archive completed review spreadsheet in the SOC documentation repository
- [ ] Note any systemic issues that require process or tooling changes

---

## Metrics Tracked

| Metric | Target |
|--------|--------|
| Permanent Owner assignments (non-break-glass) | 0 |
| Privileged assignments without PIM | 0 |
| Orphaned service principals with elevated roles | 0 |
| Average time to remediate orphaned assignments | <48 hours |
| Break-glass account unauthorized logins | 0 |

---

*MWD Oil Co. Security Operations — "Privileged access is a loan, not a gift."*
