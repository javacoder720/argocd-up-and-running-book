gpg --full-generate-key
KEY_ID=$(gpg --list-secret-keys --keyid-format=long \
    | grep sec | cut -f2 -d '/' | awk '{ print $1}')

gpg --output public.pgp --armor --export gateswang00@gmail.com
argocd gpg add public.pgp --from public.pgp
argocd gpg list
# stored in argocd-gpg-keys-cm
kubectl apply -f ch09/argocd/ch09-gpg-appproject.yaml
