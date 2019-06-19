# Deploy ingress controller

## Nginx with custom script (DaemonSet avec hostPort)

```sh
kubectl apply -f nginx-IngressControler-custom-config.yaml -n ingress-nginx

kubectl get all -n ingress-nginx
```

Vérification l'ingress controler redirige vers le default backend qui affiche : default backend - 404

```sh
http://<IP-WORKER-1>
http://<IP-WORKER-2>
```


## deploy HAP en frontal de l'ingress-controller

```sh

# se placer dans le répertoire parent du répertoire haproxy

# pour le déploiement sur AWS ADAPTER les IP et les remplacer par les IP PRIVEE des deux worker
# visiualiser la config
vim ./haproxy/haproxy.cfg

# lancer un conteneur Docker qui lance HAP avec cette configuration
docker run -d --name hap -p 80:80 -p 9999:9999 -v $(pwd)/haproxy:/usr/local/etc/haproxy:ro --restart=unless-stopped haproxy:1.8.9-alpine


```

# verifier la config

http://192.169.32.20:9999/stats
user / mot de passe : admin / admin 

