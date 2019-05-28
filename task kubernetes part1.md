---------------------------------------------------------------------------------------------------------------
# Formation Kubernetes
---------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
## Kubectl
---------------------------------------------------------------------------------------------------------------

### Installation Kubectl:
1/ Télécharger le binaire:
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```

2/ Rendre le binaire kubectl exécutable:
```bash
 chmod +x ./kubectl
```

3/ Déplacez le binaire dans le PATH:
```bash
 sudo mv ./kubectl /usr/local/bin/kubectl
```

Par défaut, la configuration de kubectl est située à ~/.kube/config 


### Configurer Kubectl:
Pour définir l'adresse IP de l'apiserver, les certificats client et les informations d'identification de l'utilisateur:
```bash
$ kubectl config set-cluster $CLUSTER_NAME --certificate-authority=$CA_CERT --embed-certs=true --server=https://$MASTER_IP
$ kubectl config set-credentials $USER --client-certificate=$CLI_CERT --client-key=$CLI_KEY --embed-certs=true --token=$TOKEN
```

Définissez le cluster comme cluster par défaut:
```bash
$ kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=$USER
$ kubectl config use-context $CONTEXT_NAME
```

Activer de l'auto-complétion en exécutant :
```bash
$ source <(kubectl completion bash)
```

Pour ajouter l'autocomplétion à votre profil:
```bash
 echo "source <(kubectl completion bash)" >> ~/.bashrc 
```


### Vérification l'état du cluster:
1/ Vérifiez la configuration de kubectl en obtenant l'état de cluster. L’URL indique que kubectl est correctement configuré pour accéder au cluster
```bash
 $ kubectl cluster-info 
 ```
 
Dans le cas contraire, vérifiez que celui-ci est correctement configuré:
```bash
 $ kubectl cluster-info dump 
```

2/ vérifier la version et l'aide Kubectl:
```bash
$ kubectl version
$ kubectl -h
```

3/ Vérifiez l'emplacement et les informations d'identification :   
```bash
$ kubectl config view 
```

4/ Vérifiez chaque composant:
```bash
$ kubectl get cs
```

5/ Obtenez les noms de vos nœuds du cluster
```bash
$ kubectl get nodes
$ kubectl describe nodes
```

6/ exécute kubectl en mode reverse-proxy et tester le serveur API et l'authentification : 
```bash
$ kubectl proxy --port=8080 &
$ Curl http://localhost:8080/
```

7/ Obtenez une liste et l'URL du reverse Proxy de l'ensemble des services demarré sur le cluster:
```bash
$ kubectl cluster-info
$ kubectl cluster-info dump
$ kubectl get all
$ kubectl get services --namespace=kube-system 
$ kubectl options
```


### Utiliser Kubectl:
Lorsque vous effectuez une opération sur plusieurs ressources, vous pouvez spécifier chaque ressource par type et nom ou spécifier un ou plusieurs fichiers:

1/ spécifier des ressources du même type:
```bash
$ kubectl get pod example-pod1 example-pod2
```

2/ spécifier plusieurs types de ressources individuellement: 
```bash
$ kubectl get pod/example-pod1 replicationcontroller/example-rc1
```

3/ spécifier les ressources avec un ou plusieurs fichiers: 
```bash
$ kubectl get pod -f ./pod.yaml
```

4/ Obtenir l'aide kubectl:
```bash
$ kubectl options
$ kuctl -h
```


### Migration de commandes
Migration des commandes impératives vers la configuration d'objet impérative:

1/ Exportez l'objet live dans un fichier de configuration d'objet yaml:
```bash
$ kubectl get <kind>/<name> -o yaml --export > xxx.yaml
```

2/ Modifer manuellement les champs du nouveau fichier.

3/ Pour la gestion d'objet ultérieure, utilisez replace exclusivement: 
```bash
$ kubectl replace -f xxx.yaml 
```



---------------------------------------------------------------------------------------------------------------
## Manifeste Template:
---------------------------------------------------------------------------------------------------------------
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: monpod
  namespace: namespace1
  annotations:
    description: my frontend
  labels:
    environment: "production"
    tier: "frontend"
spec:
  restartPolicy: Always
  securityContext:
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: container1
    image: ubuntu
    env:
    -name: envname
     value: "valenv"
    ressources:
     limits:
      memory: "200Mi"
      cpu: "1"
      ephemeral-storage: "4Gi"
     requests: 
      memory: "100Mi"
      cpu: "0.5"
      ephemeral-storage: "2Gi"
    securityContext:
     allowPrivilegeEscalation: false
    livenessProbe:
     initialDelaySeconds: 15
     timeoutSeconds: 1
     httpGet:
      path: /site
      port: 8080
      httpHeaders:
      - name: X-Custom-Header
        value: Awesome
    command: ['sh','-c','echo Hello onepoint! && sleep ]
    #args: -cpus "2"
    
    *Args:-cpus "2" dit au conteneur d'essayer d'utiliser 2 cpus. Mais le conteneur est seulement autorisé à utiliser environ 1 CPU. 
```



---------------------------------------------------------------------------------------------------------------
## Traduire un fichier Docker Compose en Kompose
---------------------------------------------------------------------------------------------------------------
Traduire un fichier Docker Compose en ressources Kubernetes (Kubernetes + Compose = Kompose)
C'est un outil de conversion (Docker Compose) pour les orchestrateurs de conteneurs (Kubernetes ou OpenShift).
http://kompose.io/

En trois étapes simples, nous vous emmènerons de Docker Compose à Kubernetes.
1/ Prenez un exemple de fichier docker-compose.yaml
2/ Exécutez "kompose up" dans le même répertoire

Alternativement, vous pouvez exécuter kompose convert et déployer avec kubectl:
Installation kompose:
```bash
curl -L https://github.com/kubernetes/kompose/releases/download/v1.1.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
```

```bash
$ kompose --file docker-voting.yml convert
$ kompose --provider openshift --file docker-voting.yml convert
```

Voir: https://kubernetes.io/docs/tools/kompose/user-guide/



---------------------------------------------------------------------------------------------------------------
## NAMESPACE:
---------------------------------------------------------------------------------------------------------------
1/ Lister tous les namespaces:
```bash
$ kubectl get namespaces
```

2/ Créer un namespace:
```bash
$ kubectl create namespace namespace1
$ kubectl create –f namespace1.yaml
```

```yaml  
apiVersion: v1
kind: Namespace
metadata:
  name: namespace1
```

3/ obtenir des informations sur un namespace:
```bash
$ kubectl describe namespaces kube-system
```

4/ Définir un namespace pour un objet:
```bash
$ kubectl --namespace=namespace1 run nginx –image=nginx
$ kubectl --namespace=namespace1 get <type>
```

5/ Définir le namespace par defaut pour toutes les commandes kubectl:
```bash
$ kubectl config set-context $(kubectl config current-context) --namespace=namespace1
$ kubectl config view | grep namespace
```

6/ Supprimer un namespace :
```bash
$ kubectl delete namespace namespace1
```



---------------------------------------------------------------------------------------------------------------
## Les Pods
---------------------------------------------------------------------------------------------------------------
1/ Création d’un fichier manifest (YAML) initial :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: monpod
  namespace: dev
spec:
  containers:
  - name: container1
    image: nginx
```

2/ Création du Pod à partir d'un fichier manifest:
```bash
$ kubectl create –f mon-fichier.yaml  (--namespace=namespace1)
(--record enregistre la commande en cours dans les annotations. Utile pour une révision ultérieure)
```

3/ Afficher les Pods en cours d’execution:
```bash
$ kubectl get pod monpod -o wide
 *(-o wide permet d'afficher le Node auquel le pod a été assigné)

$ kubectl get pod monpod --namespace=namespace1 -o yaml
 *(-o yaml "--output=yaml" spécifie d’afficher la configuration complette de l'objet)
```

4/ Voir des informations détaillées sur l'histoire et le status du Pod:
```bash
$  kubectl describe pod monpod --namespace=namespace1 
```

5/ Supprimez un Pod:
```bash
$ kubectl delete pod monpod –-namespace=namespace1
$ kubectl delete –grace-period=0 --force pod monpod --namespace=namespace1
 *(Remplacer la valeur de grace par défaut "La valeur 0 force la suppression du Pod")
```



---------------------------------------------------------------------------------------------------------------
## LimitRange & Ressources
---------------------------------------------------------------------------------------------------------------
1/ Créer un objet LimitRange
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1
    defaultRequest:
      cpu: 0.5
    type: Container
```

2/ Créez le LimitRange dans l'espace de noms
```bash
$ kubectl create -f cpu-defaults.yaml --namespace=namespace1
```

3/ Créer un Pod dans le namesapce et vérifier les ressources.
Si un conteneur est créé dans l'espace de noms namespace1 et que le conteneur ne spécifie pas ses propres valeurs pour la demande CPU et la limite de l'UC, le conteneur reçoit une demande CPU par défaut de 0,5 et une limite par défaut de 1.



---------------------------------------------------------------------------------------------------------------
## Labels & selector
---------------------------------------------------------------------------------------------------------------
1/ Attribuer des labels à un Pod:
```bash
$ kubectl label pods monpod environment=production tier=frontend
```

2/ Afficher les labels générées pour chaque pod:
```bash
$ kubectl get pods --show-labels –-namespace=namespace1
```

3/ Effectuer une recherche avec le selector equality-base:
```bash
$ kubectl get pods -l environment=production,tier=frontend
```

4/ Effectuer une recherche avec le selector set-based:
```bash
$ kubectl get pods -l 'environment in (production),tier in (frontend)'
```

5/ Supprimer des Pods avec une recherche avec le selector equality-base:
```bash
$ kubectl delete pods -l environment=production,tier=frontend
```

6/ Attacher une anotation à un Pod:
```bash
$ kubectl annotate pods monpod description='my frontend'
```

7/ Recréer plusieurs Pods avec des nom et labels différents 



---------------------------------------------------------------------------------------------------------------
## QoS pod
---------------------------------------------------------------------------------------------------------------

1/ Assigné une classe Guaranteed, Burstable et BestEffort au Pod et afficher le résultat:
```bash
$ kubectl get pod |grep -i qosClass
```



---------------------------------------------------------------------------------------------------------------
## Security Context
---------------------------------------------------------------------------------------------------------------
1/ Configurer un contexte de sécurité (mode privilége) pour un pod avec un volume:
- runAsUser: spécifie que pour tout Conteneur du Pod, le premier processus s'exécute avec l'ID utilisateur 1000. 
- fsGroup: spécifie que l'ID de groupe 2000 est associé à tous les Conteneurs du Pod.L'ID de groupe est également associé au volume monté.

```yaml
	spec:
	  securityContext:
	    runAsUser: 1000
	    fsGroup: 2000
	    seLinuxOptions:
             level: "s0:c123,c456"
	    supplementalGroups: [5678]
	  containers:
	   ...
	    securityContext:
              privileged: true
	      runAsUser: 2000
              seLinuxOptions:
               level: "s0:c123,c456"
	      allowPrivilegeEscalation: false
	      capabilities:
               add: ["NET_ADMIN", "SYS_TIME"]
```

2/ Obtenez un shell et dressez la liste des processus en cours pour vérifier que les processus s'exécutent en tant qu'utilisateur 1000
```bash
$  kubectl exec -it security-context-demo -- sh 
$  ps aux 
```

3/ Créer un fichier dans le répertoire de votre volume et vérifier la valeur de l'ID de groupe
4/ affichez les capacités du processus 1:
```bash
$ cd /proc/1
```


---------------------------------------------------------------------------------------------------------------
## Les sondes (probes)
---------------------------------------------------------------------------------------------------------------
1/ Définir une sonde d'activité qui utilise une requête EXEC:
```yaml
	spec:
	  containers:
	   ...
	   livenessProbe:
	    exec:
	     command:
	     - cat
	     - /tmp/healthy
	     #command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]  ##méthode 2 
	    initialDelaySeconds: 5
	    periodSeconds: 5
```

- periodSeconds: spécifie que kubelet doit effectuer une sonde d'activité toutes les 5 secondes (La valeur minimale est 1).
- initialDelaySeconds: indique a kubelet qu'il doit attendre 5 secondes avant d'effectuer la première sonde. 
- command: kubelet exécute la commande cat /tmp/healthy dans le conteneur.  Si la commande réussit, elle renvoie 0   (A REVOIR ET AJOUTER LIGNE CI-DESSOUS)
        *timeoutSeconds: Nombre de secondes après lequel la sonde arrive à expiration. La valeur par défaut est 1 seconde. La valeur minimale est 1.
        *successThreshold: Succès consécutifs minimum pour que la sonde soit considérée comme ayant réussi après avoir échoué. La valeur par défaut est 1. Doit être 1 pour la vivacité. La valeur minimale est 1.
        *failureThreshold: Quand un pod démarre et que la sonde échoue, Kubernetes essaiera failureThreshold avant d'abandonner. Abandonner en cas d’analyse signifie relancer le pod. En cas de test de disponibilité, le pod sera marqué comme étant non prêt. La valeur par défaut est 3. La valeur minimale est 1.

Lorsque le conteneur démarre, il exécute cette commande:
```bash
$ /bin/sh -c "touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600"
```

2/ Définir une sonde d'activité qui utilise une requête HTTPGET:
```yaml
spec:
  containers:
  ...
    livenessProbe:
	  httpGet:
	    path: /monsite
		port: 8080
		httpHeaders:
		- name: X-Custom-Header
		  value: Awesome
	     initialDelaySeconds: 3
	     periodSeconds: 3
```
Les sondes HTTP ont des champs supplémentaires qui peuvent être définis :
- host : nom d'hôte auquel se connecter, par défaut l'adresse IP du pod. 
- scheme : Schéma à utiliser pour se connecter à l'hôte (HTTP ou HTTPS). Par défaut à HTTP.
- path : Chemin d'accès sur le serveur HTTP.
- httpHeaders : en-têtes personnalisés à définir dans la requête. HTTP permet des en-têtes répétés.
- port : nom ou numéro du port auquel accéder sur le conteneur. Le nombre doit être compris entre 1 et 65535.


3/ Définir une sonde d'activité qui utilise une requête TCPSocket:
```yaml
	spec:
	  containers:
	    ...
	    - containerPort: 8080
	    readinessProbe:
	      tcpSocket:
		port: 8080
	      initialDelaySeconds: 5
	      periodSeconds: 10
	    livenessProbe:
	      tcpSocket:
		port: 8080
	      initialDelaySeconds: 15
	      periodSeconds: 20
```

- Cet exemple utilise à la fois des sondes de disponibilité (Readiness) et de vivacité (Liveness). 
- kubelet envoie la première sonde de disponibilité 5 secondes après le démarrage du conteneur. 
- Cela tentera de se connecter au conteneur sur le port 8080. Si la sonde réussit, le pod sera marqué comme prêt. 
- Le kubelet continuera à exécuter cette vérification toutes les 10 secondes.

- kubelet lancera la première sonde de vivacité 15 secondes après le début du conteneur. 
- Tout comme la sonde de disponibilité, elle tentera de se connecter au conteneur goproxy sur le port 8080. 
- Si la sonde d'activité échoue, le conteneur sera redémarré.

4/ Utiliser un port nommé:
Utiliser un ContainerPort nommé pour les contrôles d'activité HTTP ou TCP:
```yaml
	ports:
	- name: liveness-port
	  containerPort: 8080
	  hostPort: 8080

	livenessProbe:
	  httpGet:
	    path: /healthz
	    port: liveness-port
```


---------------------------------------------------------------------------------------------------------------
## Les volumes
---------------------------------------------------------------------------------------------------------------
### Pod et Volume éphémère:
1/ Définir un volume dans le Pod et le monter dans le container avec une limite.
```yaml
limite: 
	spec:
	 volumes:
	 -name: monvolume
	   emptyDir(): {}
	 containers:
	 ...
	  volumeMounts:
	  -name: monvolume
	   mountPath: /mnt/volume
          ressources:
           limits:
            memory: "200Mi"
            ephemeral-storage: 2GiB
           requests: 
            ephemeral-storage: 1GiB
```

2/ Créer le Pod puis dans un autre terminal, lancer un shell sur le conteneur:
```bash
$ kubectl exec -it container1 -- /bin/bash
```

3/ Dans le terminal d'origine, surveillez les modifications apportées


### Pod et Volume persistant (PersistentVolumeClaim):
1/ Créer un "PersistentVolume"
```bash
$  mkdir /mnt/data 
```

2/ Dans le répertoire /mnt/data , créez un fichier index.html :
```bash
$ echo 'test volume persistant' > /mnt/data/index.html
```

3/ Créer un objet PersistentVolume à partir d'un nouveau manifest :
```yaml  
	kind: PersistentVolume
	apiVersion: v1
	metadata:
	  name: mypersvol
	  labels:
	    type: local
	spec:
	  storageClassName: manual
	  capacity:
	    storage: 10Gi
	  accessModes:
	    - ReadWriteOnce
	  hostPath:
	    path: "/mnt/data"
```
*("StorageClass"  sur manual pour un PersistentVolume est utilisé pour lier les requêtes PersistentVolumeClaim à ce PersistentVolume)


4/ Afficher des informations (status) sur le PersistentVolume:
```bash
$ kubectl get pv task-pv-volume
```

5/ Crée un PersistentVolumeClaim, qui sera automatiquement lié au PersistentVolume et qui demande un volume d'au moins trois gibibytes pouvant fournir un accès en r/w pour au moins un node:
```yaml
	kind: PersistentVolumeClaim
	apiVersion: v1
	metadata:
	  name: mypersvolclaim
	spec:
	  storageClassName: manual
	  accessModes:
	    - ReadWriteOnce
	  resources:
	    requests:
	      storage: 3Gi
```

6/ Regardez à nouveau le PersistentVolume et vérifier que la sortie montre que PersistentVolumeClaim est lié à votre PersistantVolume:
```bash
$  kubectl get pv task-pv-volume 
```

7/ Créer un pod qui utilise PersistentVolumeClaim comme volume de stockage.
```yaml
...
	spec:
	  volumes:
	  - name: volume1
	    persistentVolumeClaim:
	    claimName: mypersvolclaim
	  containers:
	   ...
	    volumeMounts:
	    - mountPath: "/var/www/monsite"
	      name: volume1
```

8/ Obtenez un shell sur le conteneur et vérifiez le montage:
```bash
$  kubectl exec -it task-pv-pod -- /bin/bash 
$  kubectl get pod task-pv-pod 
```



### Projected Volume

1/ Créer un pod pour utiliser un "Projected Volume" et pour monter les secrets (ci-dessous) dans un même répertoire partagé:
```yaml
	spec:
	  containers:
	  ...
	    volumeMounts:
	    - name: all-in-one
	      mountPath: "/projected-volume"
	      readOnly: true
	  volumes:
	  - name: all-in-one
	    projected:
	      sources:
	      - secret:
		  name: user
	      - secret:
		  name: pass
```

2/ Observez les modifications apportées au pod:
```bash
$  kubectl get --watch pod test-projected-volume 
```

3/ Dans un autre terminal vérifiez que le répertoire contient vos sources projetées
```bash
$ kubectl exec -it test-projected-volume -- /bin/sh 
$ ls /projected-volume/ 
```


---------------------------------------------------------------------------------------------------------------
## Contrôle d'accès:
---------------------------------------------------------------------------------------------------------------
Le stockage configuré avec un ID de groupe (GID) permet d'écrire uniquement par Pods en utilisant le même GID. Les GID non concordants ou manquants provoquent des erreurs d'autorisation refusées. Pour réduire le besoin de coordination avec les utilisateurs, un administrateur peut annoter un PersistentVolume avec un GID. Ensuite, le GID est automatiquement ajouté à tout Pod qui utilise le PersistentVolume.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv1
  annotations:
    pv.beta.kubernetes.io/gid: "1234"
```    
Quand un Pod consomme un PersistentVolume qui a une annotation GID, le GID annoté est appliqué à tous les Conteneurs dans le Pod de la même manière que les GID spécifiés dans le contexte de sécurité du Pod.




---------------------------------------------------------------------------------------------------------------
## Les secrets
---------------------------------------------------------------------------------------------------------------
1/ Créer un secret (méthode 1):
-Créer des fichiers contenant le nom d'utilisateur et mot de passe:
```bash
	$ echo -n "admin" > ./username.txt
	$ echo -n "azerty" > ./password.txt
```
-Emballez ces fichiers dans des secrets:
```bash
$ kubectl create secret generic user --from-file=./username.txt
$ kubectl create secret generic pass --from-file=./password.txt
```

2/ Créer un secret (mMéthode 2):
```bash
$ kubectl create secret generic monsecret --from-literal=username='my-app' --from-literal=password='39528$vdg7Jb'
```

3/ Créer un secret (méthode 3):
-Créer l'object secret à partir du fichier yaml:
```yaml
	apiVersion: v1
	kind: Secret
	metadata:
	  name: monsecret
	data:
	  username: admin
	  password: azerty
```

4/ Afficher des informations sur le secret:
```bash
$  kubectl get secret  
$  kubectl describe secret monsecret -o yaml
```

5/ Créer un pod qui accède aux secret via un volume (tous les fichiers créés sur montage secret auront l'autorisation 0400):
```yaml
	...
	spec:
	  containers:
	    ...
	    volumeMounts:
	    - name: secret-volume
	      mountPath: /mnt/secret-volume
	      readOnly: true
	  volumes:
	    - name: secret-volume
	      secret:
	       secretName: monsecret
	       defaultMode: 256
```

6/ Spécifier un chemin particulier pour un item (/mnt/secret-volume/my-group/my-username à la place de /mnt/secret-volume/username) et spécifier des autorisations différentes pour différents fichiers (ici, la valeur d'autorisation de 0777): 

```yaml
	volumes:
	  - name: foo
	    secret:
	      secretName: mysecret
	      items:
	      - key: username
		path: my-group/my-username
		mode: 511
```

- Si spec.volumes[].secret.items est utilisé, seules les clés spécifiées dans les items sont projetées. 
- Pour consommer toutes les clés du secret, elles doivent toutes être répertoriées dans le champ des items.
- Toutes les clés listées doivent exister dans le secret correspondant. Sinon, le volume n'est pas créé.


7/ Créer un pod qui a accès aux secret via des variables d'environnement:

```yaml
spec:
  containers:
   ...
   env:
   - name: ENVSECRET1
     valueFrom:
      secretKeyRef:
       name: usersecret
       key: username
   - name: ENVSECRET2
     valueFrom:
       secretKeyRef:
       name: passsecret
       key: password
```


---------------------------------------------------------------------------------------------------------------
##RUN APPLICATION
---------------------------------------------------------------------------------------------------------------
### objet Kubernetes Deployment

exécuter une application à l'aide d'un objet Kubernetes Deployment.
Vous pouvez exécuter une application en créant un objet Déploiement Kubernetes et vous pouvez décrire un déploiement dans un fichier YAML.

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      # unlike pod-nginx.yaml, the name is not included in the meta data as a unique name is
      # generated from the deployment name
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

Créez un déploiement basé sur le fichier YAML:
```
$ kubectl apply -f https://k8s.io/docs/tasks/run-application/deployment.yaml
```

Afficher des informations sur le déploiement:
```
$ kubectl describe deployment nginx-deployment 
```

Répertoriez les modules créés par le déploiement:
```
$  kubectl get pods -l app=nginx 
```

Afficher des informations sur un pod:
```
$  kubectl describe pod <pod-name> 
```

Mise à jour du déploiement:
Vous pouvez mettre à jour le déploiement en appliquant un nouveau fichier YAML. 

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
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
        image: nginx:1.8 # Update the version of nginx from 1.7.9 to 1.8
        ports:
        - containerPort: 80
```

Appliquez le nouveau fichier YAML:
```
$ kubectl apply -f https://k8s.io/docs/tasks/run-application/deployment-update.yaml 
```

Regardez le déploiement créer des pods avec de nouveaux noms et supprimer les anciens pods:
```
$  kubectl get pods -l app=nginx 
```

Scaling de l'application en augmentant le nombre de réplicas:
Vous pouvez augmenter le nombre de pods dans votre déploiement en appliquant un nouveau fichier YAML.

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 4 # Update the replicas from 2 to 4
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.8
        ports:
        - containerPort: 80
```

appliquer les changements et vérifier les résultat:
```
$ kubectl get pods -l app=nginx
```


Supprimer un déploiement:
```
$  kubectl delete deployment nginx-deployment 
```

Le moyen préféré de créer une application répliquée consiste à utiliser un déploiement, qui à son tour utilise un ReplicaSet. Avant que le déploiement et ReplicaSet ont été ajoutés à Kubernetes, les applications répliquées ont été configurées à l'aide d'un ReplicationController .

