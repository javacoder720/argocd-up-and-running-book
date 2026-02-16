gpg --full-generate-key
export KEY_ID=$(gpg --list-secret-keys --keyid-format=long \
    | grep sec | cut -f2 -d '/' | awk '{ print $1}')

gpg --output public.pgp --armor --export gateswang00@gmail.com
argocd gpg add public.pgp --from public.pgp
argocd gpg list 
# stored in argocd-gpg-keys-cm

argocd proj create --file ch09/argocd/ch09-gpg-appproject.yaml
argocd app create --file ch09/argocd/ch09-gpg-signatures-application.yaml

git -c http.sslVerify=false clone \
    http://localhost:3000/upandrunning/ch09-gpg-signatures.git # https://git.upandrunning.local/upandrunning/ch09-gpg-signatures.git
cd ch09-gpg-signatures
git config --global user.signingkey $KEY_ID
# debug
export GPG_TTY=$(tty)
git commit -S -am "Updated README"
git log --show-signature
