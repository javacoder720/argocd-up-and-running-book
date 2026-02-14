# Create
kubectl apply -f ch08/argocd/projects/golist.yaml
kubectl apply -f ch08/argocd/applications/
# Delete
kubectl delete -f ch08/argocd/applications/
kubectl delete -f ch08/argocd/projects/golist.yaml

# Test
kubectl get ingress -n golist -o wide
sudo sh -c 'echo "10.96.233.37 golist-api.7f000001.nip.io golist.7f000001.nip.io" >> /etc/hosts'

curl http://golist.7f000001.nip.io
curl http://golist-api.7f000001.nip.io

# Debug
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/mariadb --versions | head -5

# roles
argocd proj role list golist
# list roles in app project (golist)
argocd proj role get golist golist-developer 
# golist = app project name
# golist-developer = role defined


# create user
kubectl edit configmap argocd-cm -n argocd
# accounts.marry: apiKey, login

# update password (updates argocd-secret)
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d
argocd account update-password --account marry --current-password "cnlDx12S693moMIR" --new-password ABCDEF123

# update policy
kubectl edit configmap argocd-rbac-cm -n argocd
# policy.csv: |
#   p, role:developers, applications, get, golist/*, allow
#   p, role:developers, applications, sync, golist/*, allow
#   g, marry, role:developers
