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
kubectl -n argocd rollout status deployment argocd-repo-server
kubectl rollout pause deployment/argocd-repo-server
kubectl apply -f ch11/configmanagementplugins/kustomize-helm-app.yaml

# test if yq avail
kubectl exec -n argocd -it deployments/argocd-repo-server -c kustomize-helm-plugin -- yq --version

# test locally
cd /Users/gateswang/Programming/Learning/devops/k8/argocd/argocd-up-and-running-book/ch11/configmanagementplugins  
export ARGOCD_ENV_RELEASE_STAGE=dev
export ARGOCD_APP_PARAMETER_REPLICA_COUNT=3
export ARGOCD_APP_PARAMETER_ENVIRONMENT=prod
export ENV_CONTENT=$(env | grep "^ARGOCD_ENV_" | sed 's/^ARGOCD_ENV_//' | awk -F= '{printf "  %s: %s\n", $1, $2}')
export PARAM_CONTENT=$(env | grep "^ARGOCD_APP_PARAMETER_" | sed 's/^ARGOCD_APP_PARAMETER_//' | awk -F= '{printf "  %s: %s\n", $1, $2}')

kustomize build --enable-helm > base.yaml
yq -n '.data.env = (strenv(ENV_CONTENT) | from_yaml) | .data.params = (strenv(PARAM_CONTENT) | from_yaml)' > input.yaml
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' base.yaml input.yaml > merged.yaml
