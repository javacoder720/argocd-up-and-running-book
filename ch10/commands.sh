yq .spec.template.spec.containers.0.livenessProbe \
    ch10/apps/golist-api/golist-api-deployment.yaml
yq .spec.template.spec.containers.0.readinessProbe \
    ch10/apps/golist-api/golist-api-deployment.yaml

# custom health
kubectl patch cm/argocd-cm -n argocd --type=merge --patch-file \
    ch10/argocd-cm-patchfile.yaml
kubectl get -n argocd cm/argocd-cm -o \
    jsonpath='{.data.resource\.customizations\.health\.argoproj\.io_Application}'

# app of apps
kubectl apply -n argocd -f \
    ch10/argocd/applications/parent.yaml

curl -L -s "https://registry.hub.docker.com/v2/repositories/bitnami/mariadb/tags/?page_size=20" \
    | jq -r '.results[].name'
kubectl delete application parent -n argocd
