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


# check
kubectl get cm kustomize-helm -n kustomize-helm -oyaml


# changes to CMP
kubectl apply -f ch11/configmanagementplugins/kustomize-helm-plugin.yml
kubectl -n argocd rollout restart deployment argocd-repo-server
kubectl rollout pause deployment/argocd-repo-server
kubectl apply -f ch11/configmanagementplugins/kustomize-helm-app.yaml

# test if yq avail
kubectl exec -n argocd -it deployments/argocd-repo-server -c kustomize-helm-plugin -- yq --version

# inspect image
kubectl get pod  argocd-repo-server-65b4c8fdd-7qk8t -o jsonpath='{.spec.containers[*].image}'
# quay.io/argoproj/argocd:v2.12.6 quay.io/argoproj/argocd:v3.3.0