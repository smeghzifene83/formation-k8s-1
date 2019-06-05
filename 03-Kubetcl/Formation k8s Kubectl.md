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

4/ Activer de l'auto-complétion en exécutant :
```bash
$ source <(kubectl completion bash)
```

Pour ajouter l'autocomplétion à votre profil:
```bash
 echo "source <(kubectl completion bash)" >> ~/.bashrc 
```

5/ vérifier la version et l'aide Kubectl:
```bash
$ kubectl version
$ kubectl -h
```



### Configurer Kubectl:
Il faut configurer kubectl en local pour pouvoir interagir avec le cluster Kubernetes (IP de l'apiserver, certificats client, Token,informations d'identification utilisateur. Spécifier une option qui existe déjà fusionnera de nouveaux champs avec les valeurs existantes pour ces champs. Par défaut, la configuration de kubectl est située à ~/.kube/config.

Pour modifier le fichier kubeconfig:
```bash
$ kubectl config -h
$ kubectl <command> --help
$ kubectl config –-kubeconfig <String of File name>
```
Pour obtenir une liste d’options globales:
```bash
$ kubectl options
```

1/ Définir une entrée de cluster dans Kubeconfig :
kubectl config set-cluster NAME [--server=server] [--certificate-authority=...] [--insecure-skip-tls-verify=true] [options]
*--insecure-skip-tls-verify=true(Désactive la vérification de certification)

```bash
$ kubectl config get-clusters
$ kubectl config set-cluster $CLUSTER_NAME --certificate-authority=ca.pem --embed-certs=true --server=https://$MASTER_IP
```
Pour supprimer le cluster:
```bash
$ kubectl config delete-cluster <$CLUSTER_NAME>
```

2/ Définir les credentials (entrée utilisateur):
```bash
$ kubectl config set-credentials -h
$ kubectl config set-credentials $USER --client-certificate=$CLI_CERT --client-key=admin-key.pem --embed-certs=true --token=$TOKEN
ou
$ kubectl config set-credentials default-admin --certificateauthority = ${CA_CERT} --client-key = ${ADMIN_KEY} --clientcertificate = ${ADMIN_CERT}
```

3/ Définissez le context par défaut dans Entrypoint k8s:
```bash
$ kubectl config get-contexts
$ kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=$USER --namespace=$namespace
$ kubectl config use-context $CONTEXT_NAME
$ kubectl config current-context

Pour supprimer un contexte spécifié de kubeconfig:
$ kubectl config delete-context <Context Name>
```

3/ Vérifier la configuration :
```bash
$ kubectl config view
```

4/ Afficher les versions d'API prises en charge sur le cluster.
```bash
$ kubectl api-versions
```



### Vérification l'état du cluster:
1/ Affiche les informations du cluster. Vérifier que kubectl est correctement configuré et a accès au cluster. 
```bash
 $ kubectl cluster-info 
 *L’URL indique que kubectl est correctement configuré pour accéder au cluster (Apiserver)
 ```
Dans le cas contraire, vérifiez que celui-ci est correctement configuré:
Affiche les informations pertinentes concernant le cluster pour le débogage et le diagnostic.
```bash
 $ kubectl cluster-info dump
 $ kubectl cluster-info dump --output-directory=/path/to/cluster-state
```

2/ Vérifiez le status de chaque composant:
```bash
$ kubectl get cs
$ kubectl get all --all-namespaces
$ kubectl get pods --all-namespaces
```

5/ Obtenez des informations sur les nodes du cluster:
```bash
$ kubectl get nodes
$ kubectl describe nodes
```

6/ Exécute kubectl en mode reverse-proxy et tester le serveur API et l'authentification : 
```bash
$ kubectl proxy
#$ kubectl proxy --port=8080 &
$ curl http://localhost:8080/
```
*kubectl proxy crée un serveur proxy entre votre ordinateur et le serveur API Kubernetes. Par défaut, il n’est accessible que localement (à partir de la machine qui l’a démarré). 

-Info Dashboard-
Une fois le serveur proxy démarré, vous devriez pouvoir accéder à Dashboard à partir de votre navigateur. Pour accéder au point de terminaison HTTPS du tableau de bord, accédez à: 
"http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

*REMARQUE: Le tableau de bord ne doit pas être exposé publiquement à l'aide de la commande kubectl proxy car elle autorise uniquement la connexion HTTP. Pour les domaines autres que localhost et 127.0.0.1 il ne sera pas possible de se connecter. Rien ne se passera après avoir cliqué sur le bouton Sign in sur la page de connexion.
https://github.com/kubernetes/dashboard/wiki/Accessing-Dashboard---1.7.X-and-above


7/ Obtenez une liste et l'URL du reverse Proxy de l'ensemble des services demarré sur le cluster:
```bash
$ kubectl get all
$ kubectl get services --namespace=kube-system 
```

8/ Baculer un node en mode maintenance ou normal:
```bash
$ kubectl drain $NODENAME
$ kubectl uncordon $NODENAME
```
Pour vider en toute sécurité un node tout en respectant les SLO d'applicationVoir: 
https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/




### Utiliser Kubectl:
Lorsque d'une opération sur plusieurs ressources, on peut spécifier chaque ressource par type d'objet et nom ou spécifier un ou plusieurs fichiers:

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

4/ Field Selectors:
Les sélecteurs de champs vous permettent de sélectionner les ressources Kubernetes en fonction de la valeur d'un ou de plusieurs champs de ressources. Les sélecteurs de champs sont essentiellement des filtres de ressources. Par défaut, aucun sélecteur / filtre n'est appliqué, ce qui signifie que toutes les ressources du type spécifié sont sélectionnées. 
metadata.name=my-service
metadata.namespace!=default
status.phase=Pending

```bash
$ kubectl get pods
$ kubectl get pods --field-selector ""
```

Vous pouvez utiliser les opérateurs = , == et != Avec des sélecteurs de champs ( = et == signifient la même chose).
```bash
$ kubectl get services --field-selector metadata.namespace!=default
```

voir: https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/

---------------------------------------------------------------------------------------------------------------
## Migration de commandes
---------------------------------------------------------------------------------------------------------------
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
