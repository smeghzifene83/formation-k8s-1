---------------------------------------------------------------------------------------------------------------
# Formation Kubernetes
---------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
## Security Cluster
---------------------------------------------------------------------------------------------------------------
https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/
https://kubernetes.io/docs/tasks/administer-cluster/highly-available-master/




---------------------------------------------------------------------------------------------------------------
## Les Nodes
---------------------------------------------------------------------------------------------------------------
Exemple pour la création d'un objet k8s de type node:
```yaml
apiVersion: v1
kind: node
metadata:
   name: < ip address of the node>
   labels:
      name: <lable name>
```
Information: Les noeuds Kubernetes peuvent être programmés sur Capacité. Les pods peuvent utiliser toute la capacité disponible sur un nœud par défaut : https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/









---------------------------------------------------------------------------------------------------------------
## Traduire un fichier Docker Compose en Kompose
---------------------------------------------------------------------------------------------------------------
Traduire un fichier Docker Compose en ressources Kubernetes (Kubernetes + Compose = Kompose)
C'est un outil de conversion (Docker Compose) pour les orchestrateurs de conteneurs (Kubernetes ou OpenShift).
http://kompose.io/

Installation kompose:
```bash
curl -L https://github.com/kubernetes/kompose/releases/download/v1.17.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
```

1/ Utilisation en trois étapes :
 - Accédez au répertoire contenant votre fichier "docker-compose.yaml"
 - Exécutez "kompose up" dans le même répertoire
 - Vérifiez le déploiement des containers dans le cluster Kubernetes "kubectl get po"

2/ Alternativement: vous pouvez exécuter kompose convert pour générer un fichier à utiliser avec kubectl.
```bash
$ kompose --file docker-convert.yml convert
$ kompose --provider openshift --file docker-convert.yml convert
```

Voir: https://kubernetes.io/docs/tools/kompose/user-guide/



---------------------------------------------------------------------------------------------------------------
## Objets:
---------------------------------------------------------------------------------------------------------------
$ kubectl get <type> <all> (--namespace=<>/ --all-namespaces) (--show-labels)
	



---------------------------------------------------------------------------------------------------------------
## Partage des espaces de noms de processus entre des conteneurs dans un pod
---------------------------------------------------------------------------------------------------------------
Lorsque le partage d'espace de noms de processus est activé, les processus d'un conteneur sont visibles par tous les autres conteneurs de ce Pod. 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shareProcessNamespace
spec:
  shareProcessNamespace: true
  containers:
  - name: nginx
    image: nginx
  - name: shell
    image: busybox
    securityContext:
      capabilities:
        add:
        - SYS_PTRACE
    stdin: true
    tty: true
```

Créer le Pod et attacher un shell:
```bash
$ kubectl create -f https://github.com/dlevray/kubernetes/blob/master/TP/shareProcessNamespace.yaml
$ kubectl exec shareProcessNamespace -c nginx -it -- bash -il
```

Vous pouvez signaler les processus dans d'autres conteneurs. 
Il est possible d'accéder à une autre image conteneur en utilisant le lien ```/proc/$pid/root``` .
```bash
# head /proc/8/root/etc/nginx/nginx.conf
```

Les processus sont visibles pour les autres conteneurs du Pod. Cela inclut toutes les informations visibles dans /proc
Les systèmes de fichiers du conteneur sont visibles par les autres conteneurs du conteneur via le lien ```/proc/$pid/root``` .











---------------------------------------------------------------------------------------------------------------
## QoS pod
---------------------------------------------------------------------------------------------------------------

1/ Assigné une classe Guaranteed, Burstable et BestEffort au Pod et afficher le résultat:
```bash
$ kubectl get pod |grep -i qosClass
```
























