# Failover and Failback Procedures
## MWD Oil Co. — Azure Hybrid DR
### Document Classification: INTERNAL — SOC / CLOUD INFRASTRUCTURE USE

> **Version:** 1.0 | **Owner:** Cloud Infrastructure / Security Operations  
> **Portfolio Project** | Loren Lawton, CISSP

---

## Normal Operations Baseline

Before executing any failover, document the current state of the following:

| System | Normal State | Verify Before Failover |
|--------|-------------|----------------------|
| Primary Hub VNet | Active, all peerings connected | ✓ |
| All Spoke VNets | Active, VMs running | ✓ |
| VPN Gateways | All tunnels UP | ✓ |
| Log Analytics | Receiving all heartbeats | ✓ |
| ASR Replication | Replication health = Healthy | ✓ |
| Storage Accounts | Replication lag <15 min | ✓ |
| Recovery Vault | Backup jobs completed | ✓ |
| Sentinel | No active P1 incidents | ✓ |
| OT Telemetry | Drill Sites A/B flowing | ✓ |

---

## Phase 1 — Disaster Declaration

1. CISO or authorized executive formally declares DR event (verbal + written in ticket)
2. Security ticket updated with declaration timestamp
3. All responders join incident bridge
4. DR execution team confirmed:
   - Cloud Infrastructure Lead
   - Security Operations Lead
   - Network Operations
   - Site Coordinators (HQ, Corpus Christi, Midland, Drill Sites)

---

## Phase 2 — Pre-Failover Checks

Before enabling DR Terraform resources:

- [ ] Confirm Azure DR region (West US 3) is operational via Azure Status page
- [ ] Confirm ASR replication status — note last recovery point timestamp
- [ ] Note storage account GRS replication lag — this is your data RPO
- [ ] Confirm DR Hub VNet Terraform state is accessible
- [ ] Confirm break-glass credentials are available (offline or in PAM vault)
- [ ] Confirm DNS TTLs — if not pre-lowered, failover DNS changes may take time to propagate
  - **Recommendation:** Lower DNS TTLs to 60 seconds 4 hours before planned failover exercises

---

## Phase 3 — Enable DR Infrastructure

```bash
# Step 1 — Navigate to DR environment
cd environments/dr

# Step 2 — Review the plan before applying
# Edit main.tf: change count = 0 to count = 1 for target resources
# Start with Hub, then add spokes as needed

terraform plan

# Step 3 — Apply DR infrastructure
terraform apply

# Expected resources to be created:
# - DR Hub VNet and subnets
# - DR NSGs
# - DR VPN Gateway (takes 30-45 minutes to provision)
# - DR Log Analytics Workspace
# - DR Recovery Services Vault
# - DR VMs (if count enabled)
# - DR Storage Accounts
```

> ⚠️ VPN Gateway provisioning takes **30–45 minutes**. Plan accordingly.

---

## Phase 4 — ASR Failover for Critical VMs

For each protected VM in Azure Site Recovery:

1. Navigate to: **Recovery Services Vault → Replicated Items**
2. Select the VM
3. Click **Failover**
4. Select the latest recovery point (or choose a point-in-time if needed)
5. Uncheck "Shut down machine before beginning failover" only if primary is confirmed gone
6. Click **OK** and monitor job progress

**Failover Order (Priority):**

| Priority | VM / System | Justification |
|----------|-------------|--------------|
| 1 | Identity / Domain Controller VM | Required by all other systems |
| 2 | Log Analytics / Sentinel | Security visibility must be restored early |
| 3 | VPN Gateway (infrastructure, not ASR) | Site connectivity |
| 4 | ERP Application Server | Business operations |
| 5 | File Servers | User access |
| 6 | OT Historian (if OT connectivity available) | Operational data |

---

## Phase 5 — DNS and Application Cutover

> DNS changes are manual steps — Terraform does not manage external DNS.

- [ ] Update public DNS records to point to DR region public IPs
  - Application load balancer endpoints
  - VPN concentrator IPs
  - Any externally accessible services
- [ ] Update internal DNS (if hosted on-premises) to reflect DR VM IPs
- [ ] Confirm DNS propagation using `nslookup` or `dig` from multiple locations
- [ ] Update application configuration files if IPs are hardcoded (document any such systems)
- [ ] Notify helpdesk of expected disruption during DNS cutover window

---

## Phase 6 — Validate Identity Access

- [ ] Confirm Entra ID sign-in is functioning (Entra ID is global — should not be impacted)
- [ ] Test MFA for at least 3 responders
- [ ] Confirm PIM activations are working in DR context
- [ ] Verify RBAC assignments are present on DR resource groups
- [ ] Test a login to Azure Portal from outside corporate network
- [ ] Confirm no Conditional Access policies are blocking DR region access

---

## Phase 7 — Validate Logging in DR

Within 30 minutes of DR environment being live:

- [ ] Log Analytics workspace in DR region receiving heartbeats
  ```kusto
  Heartbeat
  | where TimeGenerated > ago(15m)
  | summarize count() by Computer
  ```
- [ ] Sentinel workspace connected to DR Log Analytics
- [ ] Defender for Cloud showing DR resource groups
- [ ] Syslog and Windows Event sources reconnected (Azure Monitor Agent on VMs)
- [ ] Alert rules active in DR Sentinel workspace
- [ ] Security team confirms they can triage incidents from DR Sentinel

---

## Phase 8 — Validate OT Telemetry

For Drill Sites A and B:

- [ ] Confirm VPN tunnels from drill sites to DR Hub are established
- [ ] OT DMZ jump hosts accessible from DR management subnet
- [ ] Historian server (if failed over) receiving data from OT DMZ
- [ ] IoT sensor gateway data flowing to Log Analytics
- [ ] Any OT alerts surfacing in Sentinel from drill site subnets
- [ ] Contact Drill Site A and B site supervisors to confirm local OT systems are operating normally
- [ ] Confirm Safety Instrumented Systems are operating independently (air-gapped — should not be affected by cloud DR)

---

## Phase 9 — DR Steady State Operations

Once failover is validated:

- [ ] Document DR activation time (this is your actual RTO measurement)
- [ ] Communicate to all stakeholders that DR is active
- [ ] Establish reduced-team DR watch schedule (minimum 2 responders monitoring)
- [ ] Continue 30-minute status updates to CISO until declared stable
- [ ] Monitor storage replication in DR region
- [ ] Confirm backup jobs are running on DR VMs
- [ ] Identify estimated timeframe for failback planning

---

## Phase 10 — Failback Planning

Failback should not begin until:
- Primary region is confirmed fully operational
- Root cause of original disaster is identified and remediated
- Security team confirms primary environment is clean (especially post-ransomware)
- CISO approves failback

**Failback Steps:**

1. Re-establish ASR replication from DR back to primary (reverse replication)
2. Verify primary environment infrastructure is clean and operational
3. Schedule maintenance window for failback (minimize business hours impact)
4. Execute planned failover back to primary (same ASR process, reverse direction)
5. Validate all systems in primary
6. Update DNS back to primary endpoints
7. Validate logging flowing to primary Log Analytics
8. Decommission DR resources (set count = 0 in DR Terraform, apply)
9. Confirm final storage replication health in primary

---

## Phase 11 — Post-Incident Review

Within 5 business days of failback completion:

- [ ] Measure actual RTO vs 4-hour target — document variance
- [ ] Measure actual RPO vs 15-minute target — document data loss if any
- [ ] Document any manual steps not covered by runbook
- [ ] Review communication effectiveness
- [ ] Review cost of DR activation (Azure Cost Management)
- [ ] Update this document with findings
- [ ] Schedule next DR exercise (recommend quarterly tabletop, annual full activation)

---

*MWD Oil Co. — "Plan for the worst. Drill for the best."*
