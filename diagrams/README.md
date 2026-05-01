# Architecture Diagrams
## MWD Oil Co. — Azure Hybrid DR Reference Architecture

> Diagrams are maintained in draw.io format. Source files (.drawio) and exported images (.png) are stored in this directory.

---

## Diagrams To Be Created

| Filename | Description | Status |
|----------|-------------|--------|
| `01-hub-spoke-overview.drawio` | Full hub-and-spoke layout — primary and DR regions | 🔲 Pending |
| `02-network-address-plan.drawio` | IP addressing scheme across all sites and VNets | 🔲 Pending |
| `03-it-ot-segmentation.drawio` | IT vs OT network segmentation — drill site detail | 🔲 Pending |
| `04-vpn-expressroute-connectivity.drawio` | WAN connectivity — VPN tunnels and ExpressRoute placeholder | 🔲 Pending |
| `05-monitoring-logging-flow.drawio` | Log flow: VMs → Log Analytics → Sentinel → SOC | 🔲 Pending |
| `06-dr-failover-flow.drawio` | DR activation sequence and failover traffic paths | 🔲 Pending |
| `07-rbac-identity-design.drawio` | Entra ID RBAC groups, PIM activation flow | 🔲 Pending |
| `08-backup-recovery-architecture.drawio` | ASR replication flow, Recovery Vault, storage GRS | 🔲 Pending |
| `09-purdue-model-reference.drawio` | Purdue model overlay on OT subnet design | 🔲 Pending |

---

## draw.io Resources

- Desktop app: https://app.diagrams.net
- VS Code extension: `hediet.vscode-drawio`
- Export diagrams as PNG and commit both `.drawio` (source) and `.png` (display) to this directory

---

## Naming Convention

All diagram files follow this convention:
- `##-short-description.drawio` — source file
- `##-short-description.png` — exported image for README embedding

---

*Place completed diagram files in this directory and update the table above.*
