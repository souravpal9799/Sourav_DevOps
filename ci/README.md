CI - Pipelines and Release Engineering

Responsibility:
- House CI pipeline definitions, Jenkinsfiles, and any pipeline-as-code examples used to build, scan, and publish images.
- Define promotion strategy between environments (image tagging, policy gates, and rollout automation via Argo CD).

Contents (recommended):
- `ci/jenkins` – Jenkinsfile examples, environment scripts
- `pipelines/` – reusable pipeline templates and scanning steps (image scanning, IaC linting)

Operational notes:
- CI should publish immutable image tags, sign or scan images, and trigger GitOps updates rather than performing direct cluster deploys.
