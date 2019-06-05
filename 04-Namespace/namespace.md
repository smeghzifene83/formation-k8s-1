# Namespaces

```sh

# lister les namespaces
kubectl get namespaces
kubectl get ns

# creer 
kubectl create ns test

# supprimer
kubectl delete ns test

```

	
---------------------------------------------------------------------------------------------------------------
## NAMESPACE:
---------------------------------------------------------------------------------------------------------------

1/ Créer un namespace:
```yaml  
apiVersion: v1
kind: Namespace
metadata:
  name: tst
```

```bash
$ kubectl create –f namespace.yaml 
```

2/ Obtenir des informations sur un namespace:
```bash
$ kubectl get namespaces
$ kubectl describe namespaces tst
```

3/ Définir le namespace par defaut pour toutes les commandes kubectl:
```bash
$ kubectl config set-context $(kubectl config current-context) --namespace=tst
$ kubectl config view | grep namespace
```

4/ Supprimer un namespace :
```bash
$ kubectl delete namespace tst
```
 
5/ Afficher les objets qui sont ou ne sont pas dans un NameSapce:
 ```bash
$ kubectl api-resources --namespaced=true
$ kubectl api-resources --namespaced=false
```
 
 
---------------------------------------------------------------------------------------------------------------
## ResourceQuota:
---------------------------------------------------------------------------------------------------------------
1/ Créer un ResourceQuota
```yaml  
apiVersion:   v1 
kind:   ResourceQuota 
metadata: 
  name:   quota
  namespace: tst
spec: 
  hard: 
    requests.cpu:   "1" 
    requests.memory:   1Gi 
    limits.cpu:   "5" 
    limits.memory:   10Gi 
```
```bash
$ kubectl create -f resourcequota.yaml
```

2/ Afficher les ResourceQuota:
```bash
$ kubectl get resourcequota quota -n tst --output=yaml 
$ kubectl describe namespaces tst
```

3/ Modifier le fichier yaml et remplacer la configuration:
```yaml 
apiVersion:   v1 
kind:   ResourceQuota 
metadata: 
  name:   quota
spec: 
  hard: 
    limits.cpu:   "5" 
    limits.memory:   10Gi 
```

```bash
kubectl replace -f resourcequota2.yaml
```

Voir : https://kubernetes.io/docs/concepts/policy/resource-quotas/

