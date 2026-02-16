
# gen keys
ssh-keygen -t ed25519 -f argocd_ssh -C "argocd@upandrunning.local" -q -N ""
<<CMD
  -t ed25519
    key type
  -f argocd_ssh
    output file name
    argocd_ssh = private, argocd_ssh.pub = public
  -C "argocd@upandrunning.local" 
    comment in public key
  -q
    quiet mode
  -N ""
    empty passphrase
CMD

## public key exposed by gitea, needs to be added to list of known ssh hosts
kubectl run tmp-ssh2 --image=alpine -- sh -c "apk add --no-cache openssh-client >/dev/null 2>&1 && ssh-keyscan -p 2222 gitea-ssh.gitea.svc.cluster.local"
# modify
kubectl logs tmp-ssh2
kubectl logs tmp-ssh2 | sed 's/\[gitea-ssh.gitea.svc.cluster.local\]:2222/gitea-ssh.gitea/'
kubectl logs tmp-ssh2 | sed 's/\[gitea-ssh.gitea.svc.cluster.local\]:2222/gitea-ssh.gitea/' | argocd cert add-ssh --batch

# add host key
argocd cert rm gitea-ssh.gitea --cert-type ssh
kubectl logs tmp-ssh2 \
  | sed 's/\[gitea-ssh.gitea.svc.cluster.local\]:2222/[gitea-ssh.gitea]:2222/' \
  | argocd cert add-ssh --batch
argocd cert list --cert-type ssh

# remove + add repo
argocd repo list
argocd repo rm git@git.upandrunning.local:upandrunning/ch09-credentials-ssh.git
argocd repo add ssh://git@gitea-ssh.gitea:2222/upandrunning/ch09-credentials-ssh.git \
  --ssh-private-key-path argocd_ssh

