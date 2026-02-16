kubectl apply -f ch11/configmanagementplugins/kustomize-helm-plugin.yml

# inject container, uses
# 1. argocd-repo-server-kustomize-helm-plugin-patch.yaml
kubectl -n argocd patch deployments/argocd-repo-server \
    --patch-file ch11/configmanagementplugins/argocd-repo-server-kustomize-helm-plugin-patch.yaml
kubectl -n argocd rollout restart deployment argocd-repo-server
kubectl -n argocd rollout status deployment argocd-repo-server
kubectl get pods -n argocd -l=app.kubernetes.io/component=repo-server -w

# create application, uses
# 1. kustomize-helm-app.yaml
# 2. kustomization.yaml
kubectl apply -f ch11/configmanagementplugins/kustomize-helm-app.yaml
