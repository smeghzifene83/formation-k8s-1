# Deploy ingress controller

## Nginx

### with custom script

```sh
# create the namespace
kubectl create namespace ingress-nginx

kubectl apply -f nginx-IngressControler-custom-config.yaml -n ingress-nginx
```

error
```
F0609 07:35:41.190648       6 main.go:98] No service with name ingress-nginx/default-http-backend found: services "default-http-backend" is forbidden: User "system:serviceaccount:ingress-nginx:default" cannot get resource "services" in API group "" in the namespace "ingress-nginx"
```

### with official install (with Kustomize)

https://kubernetes.github.io/ingress-nginx/deploy/
https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md

```sh

# create the namespace
kubectl create namespace ingress-nginx

cat << EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ingress-nginx
bases:
- github.com/kubernetes/ingress-nginx/deploy/cluster-wide
- github.com/kubernetes/ingress-nginx/deploy/baremetal
EOF

# create the ingress controller
kubectl apply --kustomize .

# Wait, Wait, Wait ...

# check the ingress controller node port
kubectl get svc -n ingress-nginx


export NODE_PORT=$(kubectl get --namespace ingress-nginx -o jsonpath="{.spec.ports[0].nodePort}" services ingress-nginx)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Ingress controller URL: http://$NODE_IP:$NODE_PORT/"

```

