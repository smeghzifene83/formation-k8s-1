# Deploy Ingress an ingress

## Docker-demo

```sh
# si besoin, adapter le hostname docker-demo-ingress.192.169.32.20.xip.io dans le fichier docker-demo-ingress.yaml

# deployer l'ingress pour le service docker-demo-svc
kubectl apply -f docker-demo-ingress.yaml


export NODE_PORT=$(kubectl get --namespace ingress-nginx -o jsonpath="{.spec.ports[0].nodePort}" services ingress-nginx)
export INGRESS_HOSTNAME=$(get ingresses docker-demo-ingress -o jsonpath="{.spec.rules[0].host}")

echo "docker demo Ingress controller URL: http://$INGRESS_HOSTNAME:$NODE_PORT/"
#  

```