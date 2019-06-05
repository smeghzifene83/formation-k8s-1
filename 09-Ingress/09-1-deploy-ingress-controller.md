# Deploy ingress controller

## Nginx

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

