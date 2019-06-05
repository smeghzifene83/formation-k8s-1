
---------------------------------------------------------------------------------------------------------------
#  volumes
---------------------------------------------------------------------------------------------------------------

## Volume emptyDir:

1/ Répertoriez les StorageClasses du cluster:
```bash
$ kubectl get storageclass
```

2/ Définir un volume emptyDir dans le Pod et le monter dans le container avec une limite.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod9
  namespace: tst
spec:
  containers:
  - image: nginx
    name: container9
    volumeMounts:
    - mountPath: /myvolume
      name: monvolume
    #ressources:
      #limits:
      #memory: "200Mi"
      #ephemeral-storage: 2GiB
      #requests: 
      #ephemeral-storage: 1GiB
  volumes:
  - name: monvolume
    emptyDir: {}
```
   
3/ Créer le Pod puis dans un autre terminal, lancer un shell sur le conteneur:
```bash
$ kubectl exec -it simplepod9 -- /bin/bash
```

4/ Dans le terminal d'origine, surveillez les modifications apportées
$ find / -name myvolume

## PV & PVC:
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
```bash
$ kubectl create –f pv.yaml
```

4/ Afficher des informations (status) sur le PersistentVolume:
```bash
$ kubectl get pv task-pv-volume
$ kubectl describe pv task-pv-volume
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
```bash
$ kubectl create –f pvc.yaml
$ kubectl get pvc
```


6/ Regardez à nouveau le PersistentVolume et vérifier que la sortie montre que PersistentVolumeClaim est lié à votre PersistantVolume:
```bash
$  kubectl get pv task-pv-volume
$ kubectl describe pv pv0001
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
Dans le code ci-dessus, nous avons défini -
∙ volumeMounts: → Il s'agit du chemin dans le conteneur sur lequel le montage aura lieu.
∙ Volume: → Cette définition définit la définition de volume que nous allons réclamer.
∙ persistentVolumeClaim: → Sous cela, nous définissons le nom du volume que nous allons utiliser dans le module défini.


8/ Obtenez un shell sur le conteneur et vérifiez le montage:
```bash
$  kubectl exec -it task-pv-pod -- /bin/bash 
$  kubectl get pod task-pv-pod 
```



## Projected Volume

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

