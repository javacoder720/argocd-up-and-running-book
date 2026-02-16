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

curl -L -s "https://registry.hub.docker.com/v2/repositories/bitnami/mariadb/tags/?page_size=20" > tags.json
curl -L -s "https://registry.hub.docker.com/v2/repositories/bitnami/mariadb/tags/?page_size=20" \
    | jq -r '.results[].name'
kubectl delete application parent -n argocd

# debug image w/ skopeo
skopeo inspect --override-os linux docker://docker.io/bitnami/mariadb:latest
skopeo inspect --override-os linux docker://docker.io/alpine:latest

kubectl delete application parent -n argocd

# enable progressive sync
kubectl patch cm/argocd-cmd-params-cm -n argocd --type=json \
    --patch-file ch10/argocd-cmd-params-cm-patchfile.yaml
kubectl rollout restart deploy/argocd-applicationset-controller -n argocd
kubectl apply -n argocd -f ch10/argocd/appsets/progressivesync.yaml
kubectl delete applicationset golist -n argocd