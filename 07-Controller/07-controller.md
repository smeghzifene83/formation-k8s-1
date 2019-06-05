
---------------------------------------------------------------------------------------------------------------
##JOB
---------------------------------------------------------------------------------------------------------------

1/ Creer un Job
```yaml
apiVersion: v1
kind: Job   (création d’un Job de type Pod)
metadata:
   name: py
   spec:
   template:
      metadata
      name: py -------> 2
      spec:
         containers:
            - name: py ------------------------> 3
            image: python----------> 4
            command: ["python", "SUCCESS"]
            restartPocliy: Never --------> 5
```
∙ kind: Job → Nous avons défini le type de Job qui indiquera à kubectlt que le fichier yaml utilisé doit créer un module de type de travail.
∙ Nom: py → C'est le nom du modèle que nous utilisons et la spécification définit le modèle.
∙ nom: py → nous avons donné le nom py dans les spécifications de conteneur, ce qui permet d'identifier le pod qui sera créé.
Image: python → l'image que nous allons extraire pour créer le conteneur qui s'exécutera à l'intérieur du pod.
∙ restartPolicy: Jamais → Cette condition de redémarrage de l'image est donnée comme jamais, ce qui signifie que si le conteneur est tué ou s'il est faux, il ne redémarrera pas tout seul.


2/ Créer un scheduled Job
```yaml
apiVersion: v1
kind: Job
metadata:
   name: py
spec:
   schedule: h/30 * * * * ? -------------------> 1
   template:
      metadata
         name: py
      spec:
         containers:
         - name: py
         image: python
         args:
/bin/sh -------> 2
-c
ps –eaf ------------> 3
restartPocliy: OnFailure
```

 - hschedule: Pour planifier l'exécution du Job toutes les 30 minutes.
 - /bin/sh: entrer dans le conteneur avec /bin/sh
 - ps –eaf: Exécute la commande ps -eaf sur la machine et répertorie tous les processus en cours d'exécution dans un conteneur.
 
 
Pour lister tous les pods appartenant à un job sous une forme lisible par une machine:
```bash
$ pods=$(kubectl get pods --selector=job-name=pi --output=jsonpath={.items..metadata.name})
$ echo $pods
```

L'option --output=jsonpath spécifie une expression qui récupère juste le nom de chaque pod dans la liste renvoyée.
```bash
$ kubectl logs $pods
```




4/ Créer un CronJob qui exécute chaque minute un travail simple pour imprimer l'heure actuelle et ensuite dire bonjour. Toutes les modifications apportées à un travail cron, en particulier son .spec , ne seront appliquées qu'à la prochaine exécution.

Créer un CronJob:
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```
Vous pouvez également utiliser kubectl run pour créer un travail cron sans écrire la configuration complète:
```bash
$ kubectl run hello --schedule="*/1 * * * *" --restart=OnFailure --image=busybox -- /bin/sh -c "date; echo Hello from the Kubernetes cluster"
```

Vous devriez voir que "bonjour" a programmé avec succès un travail à l'heure spécifiée dans LAST-SCHEDULE .
Afficher les CronJob:
```bash
$ kubectl get cronjob 
$ kubectl get jobs –watch
```

Supprimer le CronJob:
```bash
$ kubectl delete cronjob hello
```





---------------------------------------------------------------------------------------------------------------
##ReplicaSet
---------------------------------------------------------------------------------------------------------------
Utiliser un ReplicaSet pour déployer un conteneur répliqué. . 
*L'une des fonctionnalités clés des contrôleurs de réplication comprenait la fonctionnalité de «mise à jour progressive». Cette fonctionnalité permet de mettre à jour les pods gérés par les contrôleurs de réplication avec une interruption minimale / nulle du service fourni par ces pods. Pour ce faire, les instances des anciens pods sont mises à jour une par une. Cependant, les contrôleurs de réplication ont été critiqués pour leur impératif et leur manque de flexibilité. En tant que solution, les jeux de réplicas et les déploiements ont été introduits en remplacement des contrôleurs de réplication.

1/ Créer un ReplicaSet:
```yaml
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: myrps
spec:
  replicas: 3
  selector:  #choisi les pods géré par notre ReplicaSet "Pod dont le label correspondant à ce selector". Donc un Controller peut gérer des pods qu'il n'a pas explicitement créées.
    matchLabels:
      app: nginx-replicaset
  template: # la configuration spécifique pour les pods dans ReplicaSet
    metadata:
      labels:
        app: nginx-replicaset
    spec:
      containers:  #règles d’exécution des conteneurs Docker présent de les pods
      - name: my-container 
        image: nginx  
        imagePullPolicy: IfNotPresent     # par défaut "IfNotPresent", oblige à extraire une image si elle n'existe pas
	#command: ['sh', '-c', 'echo Hello Kubernetes! &amp;&amp; sleep 3600']
        ports: #: spécifie le port utilisé par le conteneur
        - containerPort: 80
 ```  
 
*un modèle de pod dans un ReplicaSet doit spécifier les labels appropriées et une stratégie de redémarrage (la seule valeur autorisée est Always).
* Un ReplicaSet gère tous les pods avec des labels correspondant au sélecteur. Il ne fait pas la distinction entre les pods créés ou supprimés et les pods créés ou supprimés par une autre personne ou un autre processus. Cela permet de remplacer le ReplicaSet sans affecter les pods en cours d'exécution.
*vous ne devez pas créer de pod dont les labels correspondent à ce sélecteur, ni directement, ni avec un autre ReplicaSet, ni avec un autre contrôleur, tel qu'un déploiement. Si vous le faites, le ReplicaSet pense avoir créé les autres pods. Kubernetes ne vous empêche pas de le faire.
* Pour les Labels, veillez à ne pas les chevaucher avec d'autres contrôleurs.


2/ Afficher les détails du ReplicaSet:
```bash
$ kubectl describe rs/MyReplicaSet
$ kubectl describe rs frontend
```   

3/ Supprimer le ReplicaSet avec tous ces Pods:
```bash
$ kubectl delete rs frontend
```   

4/ Supprimer juste un ReplicaSet sans affecter aucun de ses pods:
```bash
$ kubectl delete rs frontend --cascade=false
```

5/ Isoler les pods d'un ReplicaSet:
Les pods peuvent être supprimés d'un ReplicaSet en modifiant leurs étiquettes.Les pods ainsi supprimés seront automatiquement remplacés (en supposant que le nombre de réplicas ne soit pas également modifié).


6/ Scaling d'un ReplicaSet:
Mettre à jour le champ .spec.replicas. Le contrôleur ReplicaSet s'assure qu'un nombre souhaité de pods avec un sélecteur correspondant au Labels sont disponibles et opérationnels.


7/ Créer le HPA défini qui met automatiquement à l'échelle le ReplicaSet cible en fonction de l'utilisation du CPU par les pods répliqués. Un ReplicaSet peut être Auto-Scaled par un HPA. 

```yaml
apiVersion:   autoscaling/v1 
  kind:   HorizontalPodAutoscaler 
  metadata: 
    name:   frontend-scaler 
  spec: 
    scaleTargetRef: 
      kind:   ReplicaSet 
      name:   frontend 
    minReplicas:   3 
    maxReplicas:   10 
    targetCPUUtilizationPercentage:   50
```

Ou, utiliser la commande kubectl autoscale pour accomplir la même chose que le HPA (Déploiement, Replica Set, Replication Controller)
```bash
$ kubectl autoscale (-f FILENAME | TYPE NAME | TYPE/NAME) [--min = MINPODS] --max = MAXPODS [--cpu-percent = CPU] [flags]
$ kubectl autoscale rs frontend --max=10
$ kubectl autoscale deployment foo --min=2 --max=10
```
