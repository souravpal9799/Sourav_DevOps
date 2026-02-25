Ops - Playbooks and Observability

Responsibility:
- Operational runbooks, Ansible playbooks, and automation for provisioning observability and platform-level services (Prometheus, Grafana, Loki, Alertmanager).
- Operational documentation for monitoring, alerting, incident response, and runbooks.

Contents (recommended):
- `ansible/monitoring` – Prometheus/Grafana/Loki roles and site plays
- `runbooks/` – incident playbooks and owner contacts

Operational notes:
- Treat these playbooks as operational tooling; production installs should be idempotent and callable from CI/GitOps workflows.
