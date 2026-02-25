# Kubernetes manifests for EKS

Deploy **frontend**, **user-service**, and **order-service** to an EKS cluster, with path-based routing via a single Ingress. Supports manual deploy and **Argo CD** (GitOps). Images are built and pushed by **GitHub Actions** to GHCR (public; no imagePullSecrets).

## Overview

| Component         | Description                                                                               |
|-------------------|-------------------------------------------------------------------------------------------|
| **Frontend**      | FastAPI app at `/`; calls user-service and order-service for testing.                     |
| **User service**  | API at `/users` (create/list users).                                                      |
| **Order service** | API at `/orders` (list orders).                                                           |
| **Ingress**       | Single load balancer: `/` → frontend, `/users` → user-service, `/orders` → order-service. |

## Prerequisites

- `kubectl` configured for your EKS cluster (`aws eks update-kubeconfig --region <region> --name <cluster-name>`)
- Images built and pushed to **GitHub Container Registry** (public). The GitHub Action does this on push to `main`/`master`.

## Image configuration

Manifests use placeholders that match the **GitHub Actions** workflow:

- **Path:** `ghcr.io/GITHUB_REPOSITORY_OWNER/<service>:IMAGE_TAG`
- **Services:** `user-service`, `order-service`, `frontend`
- **Substitution:** The workflow replaces `GITHUB_REPOSITORY_OWNER` with `github.repository_owner` and `IMAGE_TAG` with `v<run_number>` (e.g. `v42`).

So after a workflow run, images look like:

- `ghcr.io/<your-org>/user-service:v123`
- `ghcr.io/<your-org>/order-service:v123`
- `ghcr.io/<your-org>/frontend:v123`

For **Argo CD**, either use [Argo CD Image Updater](https://argocd-image-updater.readthedocs.io/) to set the image tag from the latest build, or apply the manifests produced by the workflow (see below). Public GHCR images do not require imagePullSecrets.

## GitHub Actions

Workflow: `.github/workflows/docker-publish.yml`

- **Triggers:** Push to `main`/`master`, or manual `workflow_dispatch`.
- **Steps:**
  1. Build and push **user-service**, **order-service**, and **frontend** to `ghcr.io/<owner>/<service>:v<run>` and `:latest`.
   2. Substitute `GITHUB_REPOSITORY_OWNER` and `IMAGE_TAG` in `platform/kubernetes/python_ms_k8s_manifest/app/*-deployment.yaml`.
   3. Upload the `platform/kubernetes/python_ms_k8s_manifest/app/` directory (with substituted images) as artifact **k8s-manifests**.

To deploy the exact images from a run: download the **k8s-manifests** artifact and run:

```bash
kubectl apply -f <path-to-downloaded-k8s-app>/ -R
```

## Deploy

### Option 1 – Argo CD (GitOps, recommended)

1. **Install Argo CD** (once):

   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'

   #To get admin password run 
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

   #Install the ArgoCD CLI on your local server
   curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
   sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
   rm argocd-linux-amd64

   #Then login to the shell 
   argocd login <Your_argocd_DNS> --username admin \
      --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) \
      --insecure

   #Add your Repo Credentails to the ArgoCD application
   argocd repo add https://github.com/<owner>/<repo>.git \
      --username <username> \
      --password <git_pat_token>

   #Restart the argocd-server
   kubectl rollout restart deployment argocd-server -n argocd


   ```

2. **Set your repo URL** in `platform/kubernetes/python_ms_k8s_manifest/argocd/app-application.yaml`: set `repoURL` and `targetRevision` (e.g. `main`). For private repos, add the repo in Argo CD with credentials.

3. **Apply Argo CD Applications** (Ingress controller first, then app):

   ```bash
   kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/argocd/ingress-nginx-application.yaml
   kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/argocd/app-application.yaml
   ```

   Argo CD will:

   - Install the **NGINX Ingress Controller** from the Helm chart in the `ingress-nginx` namespace.
   - Sync **frontend**, **user-service**, **order-service**, and **Ingress** from `platform/kubernetes/python_ms_k8s_manifest/app/` into the `app` namespace (with `CreateNamespace=true`, `PruneLast`, and automated selfHeal/prune).

   Pushes to the repo are detected on refresh; sync applies changes automatically.

### Option 2 – Manual (namespace `app`)

Ensure the NGINX Ingress Controller is installed (e.g. via the Argo CD Application above, or [AWS deploy YAML](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/aws/deploy.yaml)). Then:

```bash
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/namespace.yaml
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/user-service-deployment.yaml
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/order-service-deployment.yaml
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/frontend-deployment.yaml
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/services.yaml
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/hpa.yaml
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/ingress.yaml
```

Or in one go (applies all manifests in the app directory):

```bash
kubectl apply -f platform/kubernetes/python_ms_k8s_manifest/app/
```

**Note:** For manual deploy with the repo as-is, replace `GITHUB_REPOSITORY_OWNER` and `IMAGE_TAG` in the deployment files with your registry owner and tag (e.g. from the workflow), or use the manifests from the **k8s-manifests** artifact.

## Verify

```bash
kubectl get pods,svc,ingress -n app
kubectl logs -n app -l app=frontend --tail=20
kubectl logs -n app -l app=user-service --tail=20
kubectl logs -n app -l app=order-service --tail=20
```

## Ingress (path-based routing)

One host (e.g. the load balancer DNS from the Ingress controller):

| URL                     | Backend        |
|-------------------------|----------------|
| `https://<LB.dns>/`     | Frontend       |
| `https://<LB.dns>/users`| user-service   |
| `https://<LB.dns>/orders`| order-service  |

Get the external address:

```bash
kubectl get ingress -n app
```

Then open `https://<EXTERNAL-HOST>/` for the frontend (which calls both services), or hit `/users` and `/orders` directly.

## In-cluster access

From another pod in the `app` namespace:

- `http://frontend:80`
- `http://user-service:80`
- `http://order-service:80`

## Layout

| Path | Contents |
|------|----------|
| `platform/kubernetes/python_ms_k8s_manifest/app/` | App manifests directory for deployments, services, HPA, and Ingress. Used by Argo CD. |
| `platform/kubernetes/python_ms_k8s_manifest/app/namespace.yaml` | Namespace definition for the app. |
| `platform/kubernetes/python_ms_k8s_manifest/app/frontend-deployment.yaml` | Frontend Deployment manifest. |
| `platform/kubernetes/python_ms_k8s_manifest/app/user-service-deployment.yaml` | User-service Deployment manifest. |
| `platform/kubernetes/python_ms_k8s_manifest/app/order-service-deployment.yaml` | Order-service Deployment manifest. |
| `platform/kubernetes/python_ms_k8s_manifest/app/services.yaml` | Service definitions for all three services (frontend, user-service, order-service). |
| `platform/kubernetes/python_ms_k8s_manifest/app/hpa.yaml` | HPA definitions for all three services (scales on CPU > 80%). |
| `platform/kubernetes/python_ms_k8s_manifest/app/ingress.yaml` | Ingress manifest with path-based routing. |
| `platform/kubernetes/python_ms_k8s_manifest/argocd/` | Argo CD Applications: NGINX Ingress (Helm) and app (Git, path `platform/kubernetes/python_ms_k8s_manifest/app/`). |

## Autoscaling

All three services have **HorizontalPodAutoscaler** (HPA v2) configured:

- **Frontend:** 1–5 replicas (scales when CPU > 80%)
- **User-service:** 2–10 replicas (scales when CPU > 80%)
- **Order-service:** 2–10 replicas (scales when CPU > 80%)

HPA definitions are included in each service's deployment file and also consolidated in `app/hpa.yaml` for easy reference. Ensure `metrics-server` is running in the cluster for CPU metrics to be available.
