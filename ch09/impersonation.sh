kubectl patch cm/argocd-cm -n argocd --patch-file \
    ch09/argocd/ch09-impersonation-cm-patch.yaml
kubectl rollout restart statefulset -n argocd \
    -l app.kubernetes.io/component=application-controller
kubectl rollout status statefulset -n argocd \
    -l app.kubernetes.io/component=application-controller

kubectl apply -f ch09/argocd/ch09-impersonation-project.yaml
kubectl apply -f ch09/argocd/ch09-impersonation-app.yaml
kubectl get application nginx -n argocd -o yaml
# error

# fix
kubectl create namespace impersonation
kubectl create sa nginx-deployer -n impersonation
kubectl create role restricted --verb='*' --resource=deployment -n impersonation
kubectl create rolebinding restricted-binding --role=restricted \
    --serviceaccount=impersonation:nginx-deployer -n impersonation

argocd app sync --project=ch09-impersonation nginx
kubectl get deploy,pods -n impersonation
