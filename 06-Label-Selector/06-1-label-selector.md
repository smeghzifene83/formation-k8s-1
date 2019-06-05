# Labels & selector

1/ Afficher les labels générées pour chaque objets (pod, namespace, limitrange, resourcequota...) :
```bash
$ kubectl get pod --show-labels -n tst
$ kubectl get namespaces --show-labels
$ kubectl get limitrange --show-labels -n tst
$ kubectl get resourcequota --show-labels -n tst
```


2/ Attribuer des labels aux objets:
```bash
$ kubectl label pod simplepod1 -n tst tier=frontend type=pod
$ kubectl label namespace tst -n tst type=namespace
```


3/ Vérifier la présence des labels sur les objets (pod, namespace, limitrange, resourcequota...):
```bash
$ kubectl get pod --show-labels -n tst
```

3/ Effectuer une recherche avec le selector equality-base:
```bash
$ kubectl get pods -l environment=tst,tier=frontend
```
*equality-base permet de filtrer par clé et par valeur. Les objets correspondants doivent satisfaire à tous les labels spécifiées.

4/ Effectuer une recherche avec le selector set-based:
```bash
$ kubectl get pods -l 'environment in (tst),tier in (frontend)'
```

5/ Supprimer un objet par une recherche avec le selector equality-base:
```bash
$ kubectl describe po simplepod1
$ kubectl delete pods -l environment=tst,tier=frontend
```

6/ Attacher une anotation à un Pod:
```bash
$ kubectl annotate pods simplepod3 description='my frontend'
```

7/ Recréer plusieurs Pods avec des nom, labels et anotations différentes 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod1
  namespace: tst
  annotations:
    description: my frontend
  labels:
    environment: "tst"
    tier: "frontend"
```

