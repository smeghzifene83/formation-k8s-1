---------------------------------------------------------------------------------------------------------------
## Init Container
---------------------------------------------------------------------------------------------------------------

Configurer l'initialisation du pod:
comment utiliser un Init Container pour initialiser un Pod avant l'exécution d'un conteneur d'application.
créez un pod avec un conteneur d'applications et un conteneur d'initialisation. 
Le conteneur init est exécuté avant le démarrage du conteneur d'application.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  # These containers are run during pod initialization
  initContainers:
  - name: install
    image: busybox
    command:
    - wget
    - "-O"
    - "/work-dir/index.html"
    - http://kubernetes.io
    volumeMounts:
    - name: workdir
      mountPath: "/work-dir"
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
```

vous pouvez voir que le pod a un volume que le conteneur init et le conteneur d'application partagent.
Le conteneur init monte le volume partagé dans le ```/usr/share/nginx/html /work-dir``` , et le conteneur d'application monte le volume partagé dans ```/usr/share/nginx/html```. 
Le conteneur init exécute la commande suivante, puis se termine:  wget -O /work-dir/index.html http://kubernetes.io 
Notez que le conteneur init écrit le fichier index.html dans le répertoire racine du serveur nginx.



2/ Pod simple qui a deux Init Containers. Le premier attend myservice et le second attend mydb . Une fois les deux conteneurs terminés, le pod commencera.

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
  - name: init-mydb
    image: busybox
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']




---
## PodPreset

Injecter des informations dans des pods à l'aide d'un PodPreset:
Vous pouvez utiliser un objet podpreset pour injecter des informations telles que des secrets, des montages de volume et des variables d'environnement, etc. dans des pods au moment de la création.

Créer un préréglage de pod:
```yaml
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      role: frontend
  env:
    - name: DB_PORT
      value: "6379"
  volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
```

Ceci est un exemple pour montrer comment une spécification de Pod est modifiée par le préréglage de Pod qui définit une variable ConfigMap pour les variables d'environnement:

Spécification de pod soumise par l'utilisateur:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: website
  labels:
    app: website
    role: frontend
spec:
  containers:
    - name: website
      image: nginx
      ports:
        - containerPort: 80
```


Utilisateur soumis ConfigMap :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-env-config
data:
  number_of_members: "1"
  initial_cluster_state: new
  initial_cluster_token: DUMMY_ETCD_INITIAL_CLUSTER_TOKEN
  discovery_token: DUMMY_ETCD_DISCOVERY_TOKEN
  discovery_url: http://etcd_discovery:2379
  etcdctl_peers: http://etcd:2379
  duplicate_key: FROM_CONFIG_MAP
  REPLACE_ME: "a value"
```

Exemple de préréglage de pod:

```yaml
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      role: frontend
  env:
    - name: DB_PORT
      value: "6379"
    - name: duplicate_key
      value: FROM_ENV
    - name: expansion
      value: $(REPLACE_ME)
  envFrom:
    - configMapRef:
        name: etcd-env-config
  volumeMounts:
    - mountPath: /cache
      name: cache-volume
    - mountPath: /etc/app/config.json
      readOnly: true
      name: secret-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
    - name: secret-volume
      secret:
         secretName: config-details
```

Pod spec après admission controller:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: website
  labels:
    app: website
    role: frontend
  annotations:
    podpreset.admission.kubernetes.io/podpreset-allow-database: "resource version"
spec:
  containers:
    - name: website
      image: nginx
      volumeMounts:
        - mountPath: /cache
          name: cache-volume
        - mountPath: /etc/app/config.json
          readOnly: true
          name: secret-volume
      ports:
        - containerPort: 80
      env:
        - name: DB_PORT
          value: "6379"
        - name: duplicate_key
          value: FROM_ENV
        - name: expansion
          value: $(REPLACE_ME)
      envFrom:
        - configMapRef:
            name: etcd-env-config
  volumes:
    - name: cache-volume
      emptyDir: {}
    - name: secret-volume
      secret:
         secretName: config-details
```


Suppression d'un préréglage de pod:
```
$ kubectl delete podpreset allow-database podpreset "allow-database" deleted 
```




---------------------------------------------------------------------------------------------------------------
## ConfigMap
---------------------------------------------------------------------------------------------------------------
Configurer un pod pour utiliser un fichier ConfigMap:
ConfigMaps vous permet de découpler les artefacts de configuration du contenu de l'image pour garder les applications conteneurisées portables.

Exemple: La configuration dynamique de Kubelet vous permet de modifier la configuration de chaque Kubelet dans un cluster Kubernetes actif en déployant un ConfigMap et en configurant chaque nœud pour son utilisation.
https://kubernetes.io/docs/tasks/administer-cluster/reconfigure-kubelet/


comment créer des fichiers ConfigMaps et configurer des modules en utilisant des données stockées dans ConfigMaps.
créer des configmaps à partir de répertoires , de fichiers ou de valeurs littérales :
```bash
$ kubectl create configmap <map-name> <data-source>
```
- map-name est le nom que vous souhaitez attribuer à ConfigMap
- data-source est le répertoire, le fichier ou la valeur littérale dans laquelle les données doivent être dessinées.

La source de données correspond à une paire clé-valeur dans ConfigMap, où
key = le nom du fichier ou la clé que vous avez fournie sur la ligne de commande, et
value = le contenu du fichier ou la valeur littérale que vous avez fournie sur la ligne de commande.
Vous pouvez utiliser kubectl describe ou kubectl get pour kubectl get informations sur un ConfigMap.


Créer des ConfigMaps à partir de répertoires ou à partir de plusieurs fichiers du même répertoire.
```
$ kubectl create configmap game-config --from-file=https://k8s.io/docs/tasks/configure-pod-container/configmap/kubectl
$ kubectl describe configmaps game-config
$ kubectl get configmaps game-config -o yaml
```

```yaml
apiVersion: v1
data:
  game.properties: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T18:52:05Z
  name: game-config
  namespace: default
  resourceVersion: "516"
  selfLink: /api/v1/namespaces/default/configmaps/game-config
  uid: b4952dc3-d670-11e5-8cd0-68f728db1985
```



Créer des ConfigMaps à partir de fichiers:
créer un fichier ConfigMap à partir d'un fichier individuel ou de plusieurs fichiers.
```
$ kubectl create configmap game-config-2 --from-file=https://k8s.io/docs/tasks/configure-pod-container/configmap/kubectl/game.properties
```
Vous pouvez passer l'argument --from-file plusieurs fois pour créer un fichier ConfigMap à partir de plusieurs sources de données.

Utilisez l'option --from-env-file pour créer un --from-env-file ConfigMap à partir d'un fichier env, par exemple:
```
$ kubectl create configmap game-config-env-file --from-env-file=docs/tasks/configure-pod-container/game-env-file.properties
```

A VOIR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/





---------------------------------------------------------------------------------------------------------------
## Handlers
---------------------------------------------------------------------------------------------------------------
https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/
Attacher des gestionnaires aux événements du cycle de vie des conteneurs: (Handlers)
Kubernetes prend en charge les événements postStart et preStop. 
Kubernetes envoie l'événement postStart immédiatement après le démarrage d'un conteneur et envoie l'événement preStop immédiatement avant la fin du conteneur.
créez un pod avec un conteneur. Le conteneur a des gestionnaires pour les événements postStart et preStop:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
      preStop:
        exec:
          command: ["/usr/sbin/nginx","-s","quit"]
```

vous pouvez voir que la commande postStart écrit un fichier de message dans le ```/usr/share``` du conteneur. 
La commande preStop arrête nginx avec élégance. Ceci est utile si le conteneur est arrêté à cause d'un échec.
Le gestionnaire postStart s'exécute de manière asynchrone par rapport au code du conteneur, mais la gestion par Kubernetes du conteneur se bloque jusqu'à la fin du gestionnaire postStart. 
Le statut du conteneur n'est pas défini sur RUNNING tant que le gestionnaire post-démarrage n'est pas terminé.
Kubernetes envoie uniquement l'événement preStop lorsqu'un module est terminé . Cela signifie que le hook preStop n'est pas appelé lorsque le pod est terminé .












---------------------------------------------------------------------------------------------------------------
# Stateful à instance unique
---------------------------------------------------------------------------------------------------------------
Exécuter une application Stateful à instance unique:
exécuter une application stateful à instance unique dans Kubernetes en utilisant un volume PersistentVolume et un déploiement. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
  - port: 3306
  selector:
    app: mysql
  clusterIP: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
          # Use secret in real usage
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

lister les pods:
```
$ kubectl get pods -l app=mysql
```

Inspect the PersistentVolumeClaim:
```
$ kubectl describe pvc mysql-pv-claim
```


Accéder à l'instance MySQL:
Le fichier YAML précédent crée un service qui permet à d'autres modules du cluster d'accéder à la base de données. 
L'option de service clusterIP: None permet au service DNS de se résoudre directement en adresse IP du pod. 
C'est optimal quand vous n'avez qu'un Pod derrière un Service et que vous n'avez pas l'intention d'augmenter le nombre de Pods.

Exécutez un client MySQL pour vous connecter au serveur:
```
$  kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -ppassword 
```

Cette commande crée un nouveau Pod dans le cluster qui exécute un client MySQL et le connecte au serveur via le Service. S'il se connecte, vous savez que votre base de données MySQL avec état est en cours d'exécution.
Waiting for pod default/mysql-client-274442439-zyp6i to be running, status is Pending, pod ready: false
If you don't see a command prompt, try pressing enter.
mysql>




*Utiliser la strategy: type: Recreate dans le fichier YAML de configuration de déploiement. Cela indique à Kubernetes de ne pas utiliser les mises à jour tournantes. Les mises à jour tournantes ne fonctionneront pas, car vous ne pouvez pas faire tourner plus d'un pod à la fois. La stratégie Recreate arrêtera le premier pod avant d'en créer un nouveau avec la configuration mise à jour.




Supprimer un déploiement:
```
$ kubectl delete deployment,svc mysql
$ kubectl delete pvc mysql-pv-claim
```
Si vous avez manuellement provisionné un PersistentVolume, vous devez également le supprimer manuellement et libérer la ressource sous-jacente. Si vous avez utilisé un provisionneur dynamique, il supprime automatiquement le volume PersistentVolume lorsqu'il voit que vous avez supprimé PersistentVolumeClaim. 




---------------------------------------------------------------------------------------------------------------
## application Stateful répliquée
---------------------------------------------------------------------------------------------------------------
Exécuter une application Stateful répliquée:
Cette page montre comment exécuter une application dynamique répliquée à l'aide d'un contrôleur StatefulSet . L'exemple est une topologie à un seul maître MySQL avec plusieurs esclaves exécutant une réplication asynchrone.

L'exemple de déploiement de MySQL se compose d'un fichier ConfigMap, de deux services et d'un StatefulSet.
Créez le fichier ConfigMap :

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  master.cnf: |
    # Apply this config only on the master.
    [mysqld]
    log-bin
  slave.cnf: |
    # Apply this config only on slaves.
    [mysqld]
    super-read-only

```

Ce ConfigMap fournit des substitutions my.cnf qui vous permettent de contrôler indépendamment la configuration sur le maître MySQL et les esclaves. Dans ce cas, vous souhaitez que le maître puisse servir les journaux de réplication aux esclaves et que vous souhaitiez que les esclaves rejettent les écritures qui ne proviennent pas de la réplication.

Chaque Pod détermine la portion à regarder dans le configmap lors de l'initialisation, en fonction des informations fournies par le contrôleur StatefulSet.



Créez les services :

```yaml
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  clusterIP: None
  selector:
    app: mysql
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the master: mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  labels:
    app: mysql
spec:
  ports:
  - name: mysql
    port: 3306
  selector:
    app: mysql
```

Le service Headless héberge les entrées DNS que le contrôleur StatefulSet crée pour chaque pod faisant partie de l'ensemble. Comme le service Headless est nommé mysql , les pods sont accessibles en résolvant <pod-name>.mysql depuis n'importe quel autre pod du même cluster et espace-noms Kubernetes.

Le service client, appelé mysql-read , est un service normal avec son propre IP de cluster qui distribue les connexions sur tous les pods MySQL déclarant être prêts. L'ensemble des points d'extrémité potentiels comprend le maître MySQL et tous les esclaves.

Notez que seules les requêtes en lecture peuvent utiliser le service client à charge équilibrée. Parce qu'il n'y a qu'un seul maître MySQL, les clients doivent se connecter directement au Pod principal MySQL (via son entrée DNS dans le Headless Service) pour exécuter des écritures.


```yaml
StatefulSet:
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql
  replicas: 3
  template:
    metadata:
      labels:
        app: mysql
    spec:
      initContainers:
      - name: init-mysql
        image: mysql:5.7
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Generate mysql server-id from pod ordinal index.
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          echo [mysqld] > /mnt/conf.d/server-id.cnf
          # Add an offset to avoid reserved server-id=0 value.
          echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
          # Copy appropriate conf.d files from config-map to emptyDir.
          if [[ $ordinal -eq 0 ]]; then
            cp /mnt/config-map/master.cnf /mnt/conf.d/
          else
            cp /mnt/config-map/slave.cnf /mnt/conf.d/
          fi
        volumeMounts:
        - name: conf
          mountPath: /mnt/conf.d
        - name: config-map
          mountPath: /mnt/config-map
      - name: clone-mysql
        image: gcr.io/google-samples/xtrabackup:1.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          # Skip the clone if data already exists.
          [[ -d /var/lib/mysql/mysql ]] && exit 0
          # Skip the clone on master (ordinal index 0).
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          [[ $ordinal -eq 0 ]] && exit 0
          # Clone data from previous peer.
          ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql
          # Prepare the backup.
          xtrabackup --prepare --target-dir=/var/lib/mysql
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
        livenessProbe:
          exec:
            command: ["mysqladmin", "ping"]
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          exec:
            # Check we can execute queries over TCP (skip-networking is off).
            command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]
          initialDelaySeconds: 5
          periodSeconds: 2
          timeoutSeconds: 1
      - name: xtrabackup
        image: gcr.io/google-samples/xtrabackup:1.0
        ports:
        - name: xtrabackup
          containerPort: 3307
        command:
        - bash
        - "-c"
        - |
          set -ex
          cd /var/lib/mysql

          # Determine binlog position of cloned data, if any.
          if [[ -f xtrabackup_slave_info ]]; then
            # XtraBackup already generated a partial "CHANGE MASTER TO" query
            # because we're cloning from an existing slave.
            mv xtrabackup_slave_info change_master_to.sql.in
            # Ignore xtrabackup_binlog_info in this case (it's useless).
            rm -f xtrabackup_binlog_info
          elif [[ -f xtrabackup_binlog_info ]]; then
            # We're cloning directly from master. Parse binlog position.
            [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
            rm xtrabackup_binlog_info
            echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
                  MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
          fi

          # Check if we need to complete a clone by starting replication.
          if [[ -f change_master_to.sql.in ]]; then
            echo "Waiting for mysqld to be ready (accepting connections)"
            until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done

            echo "Initializing replication from clone position"
            # In case of container restart, attempt this at-most-once.
            mv change_master_to.sql.in change_master_to.sql.orig
            mysql -h 127.0.0.1 <<EOF
          $(<change_master_to.sql.orig),
            MASTER_HOST='mysql-0.mysql',
            MASTER_USER='root',
            MASTER_PASSWORD='',
            MASTER_CONNECT_RETRY=10;
          START SLAVE;
          EOF
          fi

          # Start a server to send backups when requested by peers.
          exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
            "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
      volumes:
      - name: conf
        emptyDir: {}
      - name: config-map
        configMap:
          name: mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```


Vous pouvez regarder la progression du démarrage en exécutant:
$ kubectl get pods -l app=mysql --watch


Ce manifeste utilise une variété de techniques pour gérer les Pods dynamiques dans le cadre d'un StatefulSet. 


Compréhension de l'initialisation dynamique du Pod:
Le contrôleur StatefulSet démarre les Pods une à la fois, dans l'ordre par leur index ordinal. Il attend que chaque Pod indique être prêt avant de commencer le suivant.De plus, le contrôleur attribue à chaque Pod un nom unique et stable de la forme <statefulset-name>-<ordinal-index> . 

Générer la configuration:


https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/
