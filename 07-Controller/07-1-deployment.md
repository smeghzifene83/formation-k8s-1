
# Controller Deployment

Bien que les ensembles des Controller aient toujours la capacité de gérer les pods et d’échelonner les instances de certains pods, ils ne peuvent pas effectuer de mise à jour propagée ni d’autres fonctionnalités. La méthode pour créer une application répliquée consiste à utiliser un déploiement, qui à son tour utilise un ReplicaSet. Le Deployment est un objet API de niveau supérieur qui met à jour ses ReplicaSets sous-jacents et leurs Pods de la même manière que kubectl rolling-update .

Ils ont la capacité de mettre à jour le jeu de réplicas et sont également capables de revenir à la version précédente. Ils fournissent de nombreuses fonctionnalités mises à jour de matchLabels et de sélecteurs.

1/ Exécuter une application à l'aide d'un objet Kubernetes Deployment.
```yaml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: Mydeployment
spec:
  selector:  # Utilisé pour déterminer les Pods du Cluster géré par ce controller Deployment
    matchLabels:
      app: nginx
  replicas: 2 
  template: 
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```


2/ Créez un déploiement basé sur le fichier YAML:
```bash
$ kubectl apply -f https://k8s.io/docs/tasks/run-application/deployment.yaml
ou
$ kubectl run Name-Pod --image=Image-registry:tag 
```


3/ Afficher des informations sur le déploiement:
```bash
$ kubctl get deployments
$ kubectl describe deployment nginx-deployment 
```


4/ Vérifier l'état du déploiement
```bash
$ kubectl rollout status deployment/nginx-deployment
```
Revenir au déploiement précédent
```bash
$ kubectl rollout undo deployment/Deployment --to-revision=2
```


5/ Mittre à jour la version d'image "1.8" utilisé par les Pods du Déployment et appliquer le nouveau fichier YAML. 
```bash
$ kubectl apply -f deployment-update.yaml 
ou 
$ kubectl set image deployment/Deployment tomcat=tomcat:6.0
```
Alternativement, nous pouvons edit le Déploiement et changer:
```bash
$ kubectl edit deployment/nginx
```


6/ Augmenter le "Scaling" en augmentant le nombre de réplicas (Pods) et appliquer les fichier Yaml:
```bash
kubectl apply -f deployment-scale.yaml
$ kubectl get pods -l app=nginx
ou
$ kubectl scale deployment nginx-deployment --replicas=10 
```

7/ Supprimer un déploiement:
```bash
$  kubectl delete deployment nginx-deployment 
```

## Docker-demo

1. Création

```sh
kubectl apply -f docker-demo-deployment.yaml
```

2. Affichage des détails

```sh
kubectl describe deployment docker-demo
kubectl get all --selector=app=docker-demo -o wide
```

3. Accès aux pods

```sh
curl <IP-POD-1>:8080/ping
{"instance":"docker-demo-99cf445b64-q7yqd","version":"1.0"}
curl <IP-POD-2>:8080/ping
curl <IP-POD-3>:8080/ping
``` 

4. Mise à jour


```sh
kubectl apply -f docker-demo-deployment-v2.yaml

# list
kubectl get all --selector=app=docker-demo -o wide

# Accès au POD
curl <IP-NEW-POD-1>:8080/ping
{"instance":"docker-demo-77cf445b64-q7hhd","version":"2.0"}

```

5. historique

```sh
$ kubectl rollout history deployment docker-demo
deployment.extensions/docker-demo
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

6. rollback

```sh
kubectl rollout undo deployment docker-demo

# list
kubectl get all --selector=app=docker-demo -o wide

# Accès au POD
curl <IP-NEW-POD-1>:8080/ping
{"instance":"docker-demo-77cb4697ff-795zl","version":"1.0"}

```

7. swith to specific revision

```sh

# list revision history
kubectl rollout history deployment docker-demo
deployment.extensions/docker-demo
REVISION  CHANGE-CAUSE
2         <none>
3         <none>

# swith to revision 2
kubectl rollout undo deployment docker-demo --to-revision=2

# list
kubectl get all --selector=app=docker-demo -o wide

# Accès au POD
curl <IP-NEW-POD-1>:8080/ping
 curl  10.244.1.20:8080/ping
{"instance":"docker-demo-77cf445b64-jxdhh","version":"2.0"}

```

8. scale

```sh
 kubectl scale deployment --replicas=5 docker-demo

# list
kubectl get all --selector=app=docker-demo -o wide

```



## Pour aller plus loin 
-comment exécuter une application avec état à instance unique à l'aide de PersistentVolume et d'un déploiement.:
https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/

-comment exécuter une application avec état répliquée à l'aide d'un contrôleur StatefulSet. L'exemple est une topologie mono-maître MySQL avec plusieurs esclaves exécutant une réplication asynchrone. Notez qu'il ne s'agit pas d'une configuration de production. 
https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/

-Utiliser un correctif de fusion stratégique pour mettre à jour un déploiement:
https://kubernetes.io/docs/tasks/run-application/update-api-object-kubectl-patch/
