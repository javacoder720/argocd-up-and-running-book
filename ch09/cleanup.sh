argocd app list -o name
argocd app delete ch09-credentials-https
argocd app delete ch09-gpg-signatures
argocd app delete ch09-tls
argocd app delete nginx

argocd proj list -o name
argocd proj delete ch09-gpg
argocd proj delete ch09-impersonation