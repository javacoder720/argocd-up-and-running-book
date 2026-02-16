# Test ingress
kubectl run tmp-curl --rm -it --image=curlimages/curl -- sh
curl -k -v https://argocd.upandrunning.local
curl -k https://git.upandrunning.local

# region setup 
helm upgrade -i argocd argo/argo-cd --namespace argocd --create-namespace \
  -f ch09/helm/values/values-argocd-secure.yaml
# added force-ssl-redirect & ssl-passthrough
kubectl port-forward service/argocd-server -n argocd 8080:443

# ingress
helm history ingress-nginx -n ingress-nginx | less -S
helm get values ingress-nginx -n ingress-nginx
helm get values ingress-nginx -n ingress-nginx --revision 1

# edit CoreDNS - hosts { 10.96.233.37 git.upandrunning.local  argocd.upandrunning.local}
kubectl edit configmap coredns -n kube-system
kubectl rollout restart deployment coredns -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-dns # verify
# endregion

# region create cert
openssl req -nodes -x509 -sha256 -newkey rsa:4096 \
  -keyout root.key \
  -out root.crt \
  -days 365 \
  -subj "/O=O'Reilly Media/CN=Argo CD: Up and Running Root CA" \
  -extensions v3_ca \
  -config <( \
  echo '[req]'; \
  echo 'distinguished_name=req'; \
  echo 'extensions=v3_ca'; \
  echo 'req_extensions=v3_ca'; \
  echo '[v3_ca]'; \
  echo 'keyUsage=critical,keyCertSign,digitalSignature,keyEncipherment'; \
  echo 'basicConstraints=CA:TRUE')

openssl req -nodes -x509 -sha256 -newkey rsa:4096 \
  -keyout argocd.key \
  -out argocd.crt \
  -days 365 \
  -subj "/O=O'Reilly Media/CN=argocd.upandrunning.local" \
  -extensions v3_ca \
  -CA root.crt \
  -CAkey root.key \
  -config <( \
  echo '[req]'; \
  echo 'distinguished_name=req'; \
  echo 'extensions=v3_ca'; \
  echo 'req_extensions=v3_ca'; \
  echo '[v3_ca]'; \
  echo 'keyUsage=critical,digitalSignature,keyEncipherment'; \
  echo 'subjectAltName=DNS:argocd.upandrunning.local'; \
  echo 'extendedKeyUsage=serverAuth'; \
  echo 'basicConstraints=CA:FALSE')


cat argocd.crt root.crt > argocd-fullchain.crt
kubectl create -n argocd secret tls argocd-server-tls \
  --cert=argocd-fullchain.crt \
  --key=argocd.key

# for gitea
openssl req -nodes -x509 -sha256 -newkey rsa:4096 \
  -keyout git.key \
  -out git.crt \
  -days 365 \
  -subj "/O=O'Reilly Media/CN=git.upandrunning.local" \
  -extensions v3_ca \
  -CA root.crt \
  -CAkey root.key \
  -config <( \
  echo '[req]'; \
  echo 'distinguished_name=req'; \
  echo 'extensions=v3_ca'; \
  echo 'req_extensions=v3_ca'; \
  echo '[v3_ca]'; \
  echo 'keyUsage=critical,digitalSignature,keyEncipherment'; \
  echo 'subjectAltName=DNS:git.upandrunning.local'; \
  echo 'extendedKeyUsage=serverAuth'; \
  echo 'basicConstraints=CA:FALSE')
# endregion

# region gitea
helm dependency update ch09/helm/charts/gitea
# 1. reads Chart.yaml, looks for dependencies
# 2. pulls compressed dependency charts and place into subfolder ch09/helm/charts/gitea/charts/
# 3. creates Chart.lock, records exact version of charts downloaded

helm upgrade -i --create-namespace -n gitea gitea ch09/helm/charts/gitea \
  -f ch09/helm/values/values-gitea.yaml
# ch09/helm/charts/gitea <- local path to chart
# 1. render templates
# 2. verify ns, create if needed
# 3. submit yaml to k8s
# 4. print notes

# debug
helm upgrade -i --create-namespace -n gitea gitea ch09/helm/charts/gitea \
  -f ch09/helm/values/values-gitea.yaml
kubectl delete pod gitea-postgresql-0 -n gitea

# test
kubectl port-forward -n gitea svc/gitea-http 3000:3000
# endregion

argocd login localhost:8080 --insecure

argocd cert list
argocd cert rm git.upandrunning.local

argocd app get ch09-tls
kubectl apply -f ch09/argocd/ch09-credentials-https-application.yaml
argocd repo list | less -S

# remove & add back
argocd repo rm https://git.upandrunning.local/upandrunning/ch09-credentials-https.git
argocd repo add https://git.upandrunning.local/upandrunning/ch09-credentials-https.git  \
  --username=gitea_admin --password=Argocdupandrunning1234@

# argocd.argoproj.io/secret-type=cluster
# argocd.argoproj.io/secret-type=repository
# argocd.argoproj.io/secret-type=repoc-reds
k get secret -l argocd.argoproj.io/secret-type=repository -n argocd -o yaml
kubectl get secret repo-3392146168 -n argocd -o jsonpath='{.data.password}' | base64 -d
kubectl get secret repo-3392146168 -n argocd -o jsonpath='{.data.url}' | base64 -d
