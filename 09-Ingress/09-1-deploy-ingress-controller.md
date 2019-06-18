# Deploy ingress controller

## Nginx with custom script (DaemonSet avec hostPort)

```sh
kubectl apply -f nginx-IngressControler-custom-config.yaml -n ingress-nginx

kubectl get all -n ingress-nginx
```

Vérification l'ingress controler redirige vers le default backend qui affiche : default backend - 404
http://<IP-WORKER-1>
https://<IP-WORKER-1>
http://<IP-WORKER-2>
https://<IP-WORKER-2>