---------------------------------------------------------------------------------------------------------------
## Service Account
---------------------------------------------------------------------------------------------------------------
Un compte de service fournit une identité pour les processus qui 'exécutent dans un pod. Lorsque un utilisateur accéde au cluster (ex: via kubectl), il est authentifié par l'Apiserver comme un "compte utilisateur" (actuellement "admin"). Les processus dans les conteneurs à l'intérieur des Pods peuvent également contacter l'Apiserver. Lorsqu'ils le font, ils sont authentifiés en tant que "compte de service" ("default").

1/ Créer un compte de service:
Lorsqu'un pod est créé, si vous ne spécifiez pas de compte de service, le compte de service "default" lui est automatiquement affecté dans le même NameSapce. Les autorisations API d'un compte de service dépendent du "plug-in d'autorisation" et de la "stratégie" utilisée. On peut désactiver les informations d'identification de l'API automounting pour un compte de service en définissant "automountServiceAccountToken: false" sur le compte de service.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: My-serviceAccount
automountServiceAccountToken: false
```

On peut également désactiver les informations d'identification de l'API automounting pour un pod particulier:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: My-serviceAccount
  automountServiceAccountToken: false
```
* La spécification de pod a la "priorité" sur le compte de service si les deux spécifient la valeur automountServiceAccountToken.


2/ lister toutes les ressources "serviceAccount" :
Chaque NameSapce a un ServiceAccount par default appelée "default". 
```bash
  $ kubectl get serviceAccounts
```


3/ Créer un objet ServiceAccount supplémentaires:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: My-serviceAccount2
```  
```bash
$ kubectl create -f serviceaccount2.yaml
```
Pour utiliser un compte de service particulié pour un pod, définissez lui le champ "spec.serviceAccountName"sur le nom du compte de service souhaitez. 
- Le compte de service doit exister au moment de la création du module, sinon il sera rejeté.
- Vous ne pouvez pas mettre à jour le compte de service d'un pod déjà créé.


4/ Supprimer un objets ServiceAccount :
```bash
$ kubectl delete serviceaccount/My-serviceAccount2
```

5/ Créez un jeton d'API pour un ServiceAccount:
* Créer un nouveau secret manuellement.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: Secret-My-serviceAccount
  annotations:
    kubernetes.io/service-account.name: My-serviceAccount
type: kubernetes.io/service-account-token
```

```bash
$ kubectl create -f Secret-My-serviceAccount.yaml
```

6/ Confirmer que le nouveau secret contient un jeton d'API pour le compte de service "My-serviceAccount".
```bash
$ kubectl describe secrets/Secret-My-serviceAccount
```

