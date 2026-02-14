# 1. Install the ingress controller first
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f ch03/values-ingress-nginx.yaml

# 2. Then install ArgoCD with ingress enabled
helm install argocd argo/argo-cd -n argocd --create-namespace -f ch03/values-argocd-ingress.yaml

# didnt work
curl localhost:32116
curl http://localhost
curl http://localhost:32116

# forward
kubectl port-forward svc/bgd -n bgd-blue 8082:8080
kubectl port-forward svc/bgd -n bgd-green 8083:8080

curl http://localhost:8082
