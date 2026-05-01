# Phishing Triage Procedure
## Maybe We Drill, Maybe We Don't Oil Co.
## Security Operations Center — Standard Operating Procedure

---

**Document:** SOC-RB-002  
**Version:** 1.1  
**Classification:** INTERNAL — SOC USE  
**Owner:** Security Operations Lead  
**Review Cycle:** Quarterly

---

## Purpose

This runbook covers the triage, investigation, and response process for reported phishing emails targeting MWD Oil Co. employees across all sites, including HQ San Antonio, Corpus Christi, Midland/Odessa, and drill site personnel.

---

## Phishing Report Sources

| Channel | How It Comes In |
|---------|----------------|
| Outlook "Report Phishing" button | Creates Defender for Office 365 submission |
| Employee email to `phishing@mwdoilco.example.com` | Lands in SOC phishing mailbox |
| Helpdesk ticket | Routed to SOC automatically |
| Direct Sentinel alert | Defender for O365 advanced threat detection |
| Vendor/partner report | Inbound email or phone to SOC |

---

## Step 1 — Receive and Triage the Report

- [ ] Retrieve reported email from submission portal or phishing mailbox
- [ ] Open a security ticket: classify as "Phishing - Reported"
- [ ] Record: reporter name, site, timestamp, subject line, sender address
- [ ] Do NOT click any links or open attachments in a production environment
- [ ] Assess initial urgency:
  - Did the user click a link or open an attachment?
  - Did the user enter credentials or MFA codes?
  - Does the email target a privileged user (exec, IT admin, finance)?

---

## Step 2 — Email Header Analysis

Extract and analyze the email headers:

- [ ] **From:** address — does the display name match the domain?
- [ ] **Reply-To:** — does it differ from the From address?
- [ ] **Return-Path:** — matches the sender domain?
- [ ] **Received:** chain — trace the originating mail server IP
- [ ] **Authentication-Results:** — check SPF, DKIM, DMARC pass/fail
- [ ] **X-Mailer / User-Agent:** — unusual or bulk-mail indicators?

**Quick checks:**
```
SPF: PASS = sender IP authorized | FAIL = spoofed sender
DKIM: pass = message not tampered | fail = modified in transit
DMARC: pass = aligned | fail = likely spoofed domain
```

Lookup originating IP at:
- https://mxtoolbox.com/blacklists.aspx
- https://www.virustotal.com (paste IP or domain)

---

## Step 3 — URL and Attachment Analysis

**URLs:**
- [ ] Extract all URLs from the email body (do not click)
- [ ] Submit URLs to VirusTotal: https://www.virustotal.com
- [ ] Check URL category in Defender for O365 Safe Links report
- [ ] Check domain registration age (new domains = high suspicion)
- [ ] If URL matches a credential harvesting page: escalate to P2 immediately

**Attachments:**
- [ ] Do NOT open attachments on a production workstation
- [ ] Submit attachment hash (SHA256) to VirusTotal
- [ ] Check Defender for O365 Safe Attachments report for detonation results
- [ ] If attachment is a macro-enabled Office file or executable: treat as malicious

---

## Step 4 — Determine Scope

- [ ] Search email environment for identical messages sent to other employees:
  ```
  # Defender for O365 — Threat Explorer
  Search by: Sender domain, subject line, URL, attachment hash
  ```
- [ ] Query Sentinel for related sign-in events from affected users:
  ```kusto
  SigninLogs
  | where TimeGenerated > ago(4h)
  | where UserPrincipalName in ("REPORTED_USER_UPN")
  | project TimeGenerated, IPAddress, Location, AppDisplayName, ResultType
  ```
- [ ] Check for successful logins from unusual locations or IPs for affected users
- [ ] Identify if drill site personnel (OT-adjacent roles) were targeted — elevated priority

---

## Step 5 — Containment Actions

### If user DID NOT click or interact:
- [ ] Purge the email from all mailboxes using Defender for O365 (soft/hard delete)
- [ ] Block sender domain in Exchange transport rules or Defender allow/block list
- [ ] Notify the reporting employee — confirm no action was taken
- [ ] Close ticket as contained

### If user clicked a link but did NOT enter credentials:
- [ ] Preserve: capture browser history and endpoint logs if possible
- [ ] Isolate endpoint via Defender for Endpoint if device is managed
- [ ] Run full AV/EDR scan on the user's workstation
- [ ] Monitor user account for anomalous activity for 72 hours
- [ ] Reset user session tokens in Entra ID (Revoke sign-in sessions)

### If user entered credentials or MFA codes:
- [ ] **Immediately reset the user's password** — do not wait
- [ ] **Revoke all active sessions** in Entra ID: Users → [User] → Revoke sessions
- [ ] Enable MFA re-registration requirement
- [ ] If user is privileged (admin, finance, exec): escalate to P1 and notify CISO
- [ ] Review all activity on the account for the past 24–72 hours
- [ ] Check for new OAuth app grants or inbox rules created by the attacker
- [ ] Check for forwarding rules that could exfiltrate email:
  ```
  # Defender for O365 — check for forwarding rules
  Get-InboxRule -Mailbox "user@mwdoilco.example.com" | Select Name, ForwardTo, RedirectTo
  ```
- [ ] If OT personnel or field ops staff were compromised: notify OT team for lateral movement assessment

---

## Step 6 — Indicators of Compromise (IOC) Harvesting

Document and submit IOCs to threat intelligence platform (if available):

- [ ] Sender email address and domain
- [ ] Originating IP address
- [ ] URLs in the email
- [ ] Attachment SHA256 hashes
- [ ] Subject line and body patterns (for email gateway block rules)

---

## Step 7 — Communication and Closure

- [ ] Notify the reporting employee of findings and outcome
- [ ] If large-scale campaign detected: send all-staff advisory (approved by CISO)
- [ ] Update ticket with full timeline, evidence, and remediation steps
- [ ] Submit analytics rule improvement request if Sentinel did not auto-detect
- [ ] Schedule follow-up phishing awareness training if user was successfully deceived

---

## Drill Site — Special Considerations

Employees at Drill Site A and Drill Site B may have limited IT support and may not recognize phishing indicators. If drill site personnel are targeted:

- Notify the site supervisor directly by phone — do not rely on email alone
- If the phish targeted OT vendor credentials or remote access portals: treat as P1
- Escalate to CISO if any OT or field control system credentials may be compromised

---

*MWD Oil Co. Security Operations — "One click can shut down a rig. Triage with that in mind."*
