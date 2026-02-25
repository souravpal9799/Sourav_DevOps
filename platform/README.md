Platform - Kubernetes, Helm, and GitOps

Responsibility:
- Host Kubernetes manifests, Helm charts, Argo CD application definitions, and cluster-bootstrapping resources.
- Define manifest structure for apps vs. cluster infra so GitOps can own application lifecycle independently from cluster bootstrap.

Contents (recommended):
- `platform/kubernetes/helm_charts` – curated Helm charts for platform components (ingress, cert-manager)
- `platform/kubernetes/python_ms_k8s_manifest/argocd` – Argo CD Application manifests used to reconcile applications
- `platform/kubernetes/python_ms_k8s_manifest/app` – application manifests (one folder per app/environment)

Operational notes:
- Keep cluster bootstrap manifests in a separate repo or path from app manifests to reduce blast radius and enable safer GitOps promotion.
