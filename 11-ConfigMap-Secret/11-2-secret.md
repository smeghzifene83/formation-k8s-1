
# Les secrets

## Créer des secrets:

Il existe de nombreuses façons de créer des secrets dans Kubernetes.

1/ méthode 1: Création à partir de fichiers txt
-Créer des fichiers contenant le nom d'utilisateur et mot de passe:
```bash
$ echo -n "admin" > ./username.txt
$ echo -n "azerty" > ./password.txt
ou
echo -n '123456dfg45' | base64 >> ./password.txt
```
- Emballez ces fichiers dans des secrets:
```bash
$ kubectl create secret generic user --from-file=./username.txt
$ kubectl create secret generic pass --from-file=./password.txt
```

2/ Méthode 2: Créer à partir d'une commande k8s
```bash
$ kubectl create secret generic monsecret --from-literal=username='my-app' --from-literal=password='39528$vdg7Jb'
```

3/ méthode 3: Créer à partir d'un fichier yaml
-Créer l'object secret à partir du fichier yaml:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: monsecret
  namespace: tst
data:
  username: admin
  password: azerty
```

```bash
$ kubectl create –f Secret.yaml
```

4/ Afficher des informations sur le secret:
```bash
$  kubectl get secret  
$  kubectl describe secret monsecret -o yaml
```

## Utiliser des secrets
Une fois que nous avons créé les secrets, il peut être consommé dans un pod ou un contrôleur en tant que: 
 - Variable d'environnement
 - volume

5/ Créer un pod qui accède aux secret via un volume (tous les fichiers créés sur montage secret auront l'autorisation 0400):
```yaml
...
spec:
  containers:
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
Afin d'utiliser la variable secrète comme variable d'environnement, nous utiliserons env dans la section spec du fichier pod yaml.
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

Voir aussi: activer et configurer le cryptage des données:
https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/



## Utiliser les secrets avec les images
---------------------------------------------------------------------------------------------------------------
Pull une image d'un registre privé:
créer un pod qui utilise un secret pour extraire une image d'un registre Docker privé ou d'un référentiel.

vous devez vous authentifier auprès d'un registre afin d'extraire une image privée:

```bash
$  docker login 
```

Le processus de connexion crée ou met à jour un fichier config.json contenant un jeton d'autorisation.

Créer un secret dans le cluster qui contient votre jeton d'autorisation
Créez ce secret, en le nommant regcred :
```bash
$ kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```
Vous avez correctement défini vos informations d'identification Docker dans le cluster sous la forme d'un secret appelé regcred .

consulter le format Secret au format YAML:
```bash
$ kubectl get secret regcred --output=yaml 
```
La valeur du champ .dockerconfigjson est une représentation base64 de vos informations d'identification Docker.

Pour comprendre ce qui se trouve dans le champ .dockerconfigjson , convertissez les données secrètes dans un format lisible:

```bash
$ kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 -d
```
Notez que les données secrètes contiennent le jeton d'autorisation similaire à votre fichier local ```~/.docker/config.json```.


Créer un pod qui utilise votre secret:
Voici un fichier de configuration pour un pod qui doit avoir accès à vos informations d'identification Docker dans regcred :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred
```  
remplacez <your-private-image> par le chemin d'accès à une image dans un registre privé tel que:  janedoe/jdoe-private:v1 
Le champ imagePullSecrets du fichier de configuration spécifie que Kubernetes doit obtenir les informations d'identification d'un secret nommé regcred .

Créez un pod qui utilise votre secret et vérifiez que le pod est en cours d'exécution:
$ kubectl create -f my-private-reg-pod.yaml
$ kubectl get pod private-reg

