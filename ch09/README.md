# Chapter 09 - Securing Argo CD

## Prerequisites

Make sure you have the ingress-nginx and Argo CD Helm repos already added.

## 1. Update nginx-ingress to enable SSL passthrough

```bash
helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f ch09/helm/values/values-ingress-nginx-ssl-passthrough.yaml
```

## 2. Install Gitea (local Git server)

```bash
helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo update

helm install gitea gitea-charts/gitea \
  -n gitea --create-namespace \
  -f ch09/helm/values/values-gitea.yaml \
  -f ch09/helm/charts/gitea/values.yaml
```

## 3. Add local DNS entries

```bash
sudo sh -c 'echo "127.0.0.1 git.upandrunning.local argocd.upandrunning.local" >> /etc/hosts'
```

## 4. Wait for Gitea pods to be ready

```bash
kubectl get pods -n gitea -w
```

## 5. Apply Argo CD resources

Apply the manifests from `argocd/` as needed per topic:

| File | Topic |
|------|-------|
| `ch09-credentials-https-application.yaml` | HTTPS repo credentials |
| `ch09-credentials-ssh-application.yaml` | SSH repo credentials |
| `ch09-tls-application.yaml` | TLS configuration |
| `ch09-gpg-appproject.yaml` | GPG signature verification (project) |
| `ch09-gpg-signatures-application.yaml` | GPG signature verification (app) |
| `ch09-impersonation-cm-patch.yaml` | Impersonation config patch |
| `ch09-impersonation-project.yaml` | Impersonation project |
| `ch09-impersonation-app.yaml` | Impersonation application |

```bash
kubectl apply -f ch09/argocd/<filename>
```

## Sample App

A sample nginx deployment is available at `manifests/nginx/nginx-deployment.yaml`, used as the target app for these exercises.
