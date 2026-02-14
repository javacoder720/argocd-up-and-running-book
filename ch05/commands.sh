kubectl port-forward svc/pricelist -n pricelist 8081:8080
kubectl exec -it deployment/mysql -n pricelist -- mysql -u pricelist -ppricelist pricelist
