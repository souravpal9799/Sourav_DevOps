Apps - Sample Applications and Manifests

Responsibility:
- Contain sample application manifests, Dockerfiles, and Helm chart wrappers used as examples for onboarding and testing the platform.
- Provide minimal, opinionated app layouts that demonstrate readiness/liveness probes, resource requests/limits, and GitOps-friendly deployments.

Contents (recommended):
- `platform/kubernetes/python_ms_k8s_manifest` – example microservices and Argo CD application
- `mongo_repset_visualization` – example stateful app with docker-compose and k8s counterparts

Operational notes:
- Keep these apps small and well-instrumented; they are teaching artifacts and smoke-test payloads for the platform.
