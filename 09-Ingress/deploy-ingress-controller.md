# Deploy ingress controller

## Nginx

https://kubernetes.github.io/ingress-nginx/deploy/
https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md

```sh
kubectl create namespace ingress-nginx

cat << EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ingress-nginx
bases:
- github.com/kubernetes/ingress-nginx/deploy/cluster-wide
- github.com/kubernetes/ingress-nginx/deploy/baremetal
EOF

kubectl apply --kustomize .

```