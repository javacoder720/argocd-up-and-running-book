# didnt work
argocd app set bgd-blue --sync-policy none
argocd app set bgd-green --sync-policy none

kubectl get applicationsets -n argocd
argocd appset delete bgd
