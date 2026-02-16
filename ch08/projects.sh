argocd account get-user-info

argocd proj list -o name
argocd proj create golist \
    --src '*' --dest '*,*' --allow-cluster-resource '*/*'
argocd proj create --upsert --file ch08/argocd/projects/golist.yaml # declarative

argocd app create --file ch08/argocd/applications/golist-db.yaml
argocd app list -o name --project=golist
