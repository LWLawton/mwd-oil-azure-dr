output "rbac_design_summary" {
  description = "RBAC group design reference for MWD Oil Co."
  value = <<-EOT
    ============================================================
    MWD Oil Co. — RBAC Group Design (Conceptual)
    ============================================================
    Group                  | Role                          | Scope
    -----------------------|-------------------------------|------------------
    mwd-cloud-admins       | Owner (PIM, JIT only)         | Subscription
    mwd-security-ops       | Security Reader               | Subscription
    mwd-security-ops       | Sentinel Contributor          | Monitoring RG
    mwd-network-ops        | Network Contributor           | Network RGs
    mwd-vm-ops             | VM Contributor                | Compute RGs
    mwd-readonly           | Reader                        | Subscription
    mwd-ot-admins          | Contributor                   | OT RGs only
    ============================================================
    All groups should be managed via PIM for elevated roles.
    No persistent Owner or Contributor at subscription scope.
    ============================================================
  EOT
}
